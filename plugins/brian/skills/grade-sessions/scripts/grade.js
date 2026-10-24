export const meta = {
  name: 'grade-sessions',
  description: 'Grade Claude Code sessions on Claude and Brian, then synthesize recurring patterns',
  phases: [
    { title: 'Grade', detail: 'one sonnet grader per batch' },
    { title: 'Regrade', detail: 'one more pass over sessions a grader dropped' },
    { title: 'Synthesize', detail: 'one opus agent ranks recurring patterns' },
  ],
}

// args: { batches: string[][], rubricPath: string, skillsDir: string }

const SCALE = { type: 'integer', minimum: 1, maximum: 5 }
const CATEGORIES = ['misread-intent', 'broke-rule', 'wrong-fact', 'overreach', 'underreach', 'process', 'style', 'other']
const SESSION = {
  type: 'object',
  properties: {
    file: { type: 'string', description: 'the transcript path, exactly as given' },
    task: { type: 'string', description: 'one sentence: what Brian wanted' },
    skillsUsed: { type: 'array', items: { type: 'string' }, description: 'skill names as they appear in the transcript, e.g. brian:commit' },
    claude: {
      type: 'object',
      properties: { outcome: SCALE, intent: SCALE, ruleAdherence: SCALE, efficiency: SCALE, honesty: SCALE, autonomy: SCALE },
      required: ['outcome', 'intent', 'ruleAdherence', 'efficiency', 'honesty', 'autonomy'],
    },
    user: {
      type: 'object',
      properties: { clarity: SCALE, context: SCALE, feedback: SCALE },
      required: ['clarity', 'context', 'feedback'],
    },
    corrections: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          quote: { type: 'string', description: "Brian's words, verbatim, trimmed to the relevant part" },
          category: { type: 'string', enum: CATEGORIES },
          whatClaudeDid: { type: 'string' },
          attribution: { type: 'string' },
        },
        required: ['quote', 'category', 'whatClaudeDid', 'attribution'],
      },
    },
    userMisses: { type: 'array', items: { type: 'string' } },
    bestMoment: { type: 'string' },
    worstMoment: { type: 'string' },
    rationale: { type: 'string', description: '2-4 sentences justifying the grades' },
  },
  required: ['file', 'task', 'skillsUsed', 'claude', 'user', 'corrections', 'userMisses', 'bestMoment', 'worstMoment', 'rationale'],
}
const BATCH = { type: 'object', properties: { sessions: { type: 'array', items: SESSION } }, required: ['sessions'] }

const gradePrompt = files => `Read ${args.rubricPath} and grade each of these transcripts by it (the skills directory is ${args.skillsDir}), returning one entry per file with "file" set to the path as written here:
${files.map(file => `- ${file}`).join('\n')}`

const gradeBatches = (batches, phaseTitle) => parallel(batches.map((files, index) => () =>
  agent(gradePrompt(files), { label: `${phaseTitle.toLowerCase()}:batch-${index}`, phase: phaseTitle, schema: BATCH, model: 'sonnet' })))

const expected = args.batches.flat()
const graded = new Map()
const keep = results => results.filter(Boolean).flatMap(result => result.sessions)
  .filter(session => expected.includes(session.file))
  .forEach(session => graded.set(session.file, session))

phase('Grade')
keep(await gradeBatches(args.batches, 'Grade'))
const dropped = args.batches.map(files => files.filter(file => !graded.has(file))).filter(files => files.length)
if (dropped.length) {
  phase('Regrade')
  log(`regrading ${dropped.flat().length} dropped sessions`)
  keep(await gradeBatches(dropped, 'Regrade'))
}
const ungraded = expected.filter(file => !graded.has(file))
log(`${graded.size}/${expected.length} sessions graded`)

const round = value => Math.round(value * 100) / 100
const average = values => values.length ? round(values.reduce((sum, value) => sum + value, 0) / values.length) : null
const projectOf = file => file.split('/').pop().split('__')[0]
const sessions = [...graded.values()].map(session => ({
  ...session,
  project: projectOf(session.file),
  claudeOverall: round((2 * session.claude.outcome + 2 * session.claude.intent + session.claude.ruleAdherence
    + session.claude.efficiency + session.claude.honesty + session.claude.autonomy) / 8),
  userOverall: round((session.user.clarity + session.user.context + session.user.feedback) / 3),
}))

const groupAverages = keysOf => {
  const groups = {}
  for (const session of sessions) for (const key of keysOf(session)) (groups[key] ||= []).push(session)
  return Object.fromEntries(Object.entries(groups).map(([key, members]) => [key, {
    sessions: members.length,
    claude: average(members.map(member => member.claudeOverall)),
    user: average(members.map(member => member.userOverall)),
    corrections: members.reduce((sum, member) => sum + member.corrections.length, 0),
  }]))
}
const dimensionAverages = {
  claude: Object.fromEntries(Object.keys(SESSION.properties.claude.properties).map(dimension => [dimension, average(sessions.map(session => session.claude[dimension]))])),
  user: Object.fromEntries(Object.keys(SESSION.properties.user.properties).map(dimension => [dimension, average(sessions.map(session => session.user[dimension]))])),
  claudeOverall: average(sessions.map(session => session.claudeOverall)),
  userOverall: average(sessions.map(session => session.userOverall)),
}
const byProject = groupAverages(session => [session.project])
const bySkill = groupAverages(session => session.skillsUsed.length ? session.skillsUsed : ['(no skill)'])
const correctionsByCategory = Object.fromEntries(CATEGORIES.map(category => [category,
  sessions.reduce((sum, session) => sum + session.corrections.filter(correction => correction.category === category).length, 0)]))

phase('Synthesize')
const synthesis = await agent(`You are synthesizing grades of ${sessions.length} Claude Code sessions between Brian and Claude, graded by the rubric in ${args.rubricPath}. claudeOverall weights outcome and intent double. Brian reads your report to decide which skills, CLAUDE.md rules, output-style rules, and prompting habits to change.

Aggregates:
${JSON.stringify({ dimensionAverages, correctionsByCategory, byProject, bySkill }, null, 1)}

All sessions:
${JSON.stringify(sessions)}

Write a markdown report:
1. Claude's recurring failure patterns, ranked by frequency times severity, where severity is how much rework Brian had to drive. For each: a name, how many sessions, two or three of Brian's verbatim quotes with the session file, the rule or skill implicated, and the concrete edit that would prevent it, naming the file. Read the implicated files (skills under ${args.skillsDir}, ~/.claude/CLAUDE.md, project CLAUDE.md files, the output-style files the rubric points graders to, and code a pattern traces to) so each edit quotes the current text it changes.
2. Brian's recurring patterns as a prompter, ranked the same way, each with quotes and a concrete habit change.
3. What works: patterns in the highest-graded sessions worth keeping.
4. Outliers: the three lowest and three highest sessions for each side, one line each.
Ground every claim in the session data and the files you read.`, { label: 'synthesize', phase: 'Synthesize', model: 'opus' })

return { dimensionAverages, correctionsByCategory, byProject, bySkill, ungraded, synthesis, sessions }
