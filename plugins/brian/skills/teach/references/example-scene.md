# Example level

One finished level from a lesson on web requests, shown for its structure and drawing technique, with its still drawings and its animation. Each lesson works out its own objects, layout, and steps. Coordinates are in the SVG's viewBox units.

## Markup

```html
<section id="level-1">
      <h2>Level 1: Asking for a page</h2>
      <div class="row">
        <div>
          <p>Say you want a pancake recipe from a site called pancakes.example. The recipe page is kept on another computer, so yours has to ask for it.</p>
          <p>Two things take part. Your <strong>browser</strong> is the app you open websites with, such as Safari or Chrome. A <strong>server</strong> is a computer that stays switched on, keeps a website's pages, and hands them out when asked.</p>
        </div>
        <figure id="l1-why"><svg viewBox="0 0 360 200" role="img" aria-label="Your computer on the left, and far away on the right, a server holding the pancake page."></svg></figure>
      </div>
      <div class="row wide-left">
        <figure id="scene-1">
          <svg viewBox="0 56 560 200" role="img" aria-label="A person types into a browser. The browser sends a request across the internet to a server. The server sends back a response, and the browser shows the pancake page.">
            <defs><clipPath id="l1-typed"><rect id="l1-typed-rect" x="114" y="84" width="0" height="24"/></clipPath></defs>
            <g class="layer">
              <g class="part you">
                <g id="l1-you"></g>
                <text x="120" y="99" font-size="10.5" clip-path="url(#l1-typed)">pancakes.example</text>
                <g id="l1-page" opacity="0">
                  <g id="l1-page-art"></g>
                  <text x="116" y="130" font-size="14" font-weight="600">Pancakes</text>
                </g>
                <text x="54" y="238" font-size="14" text-anchor="middle">You</text>
                <text x="172" y="238" font-size="14" text-anchor="middle">Your browser</text>
              </g>
              <g class="part net">
                <g id="l1-net"></g>
                <text x="325" y="238" font-size="14" text-anchor="middle">The internet</text>
              </g>
              <g class="part server">
                <g id="l1-server"></g>
                <text x="465" y="238" font-size="14" text-anchor="middle">Server</text>
              </g>
              <g id="l1-ground"></g>
              <g id="l1-req" opacity="0">
                <g id="l1-req-art"></g>
                <text y="5" font-size="14" text-anchor="middle">Request</text>
              </g>
              <g id="l1-res" opacity="0">
                <g id="l1-res-art"></g>
                <text y="5" font-size="14" text-anchor="middle">Response</text>
              </g>
            </g>
          </svg>
          <div class="progress" aria-hidden="true"></div>
          <div class="caption" aria-hidden="true"></div>
          <ol class="steps">
            <li>You type an address into your browser: pancakes.example.</li>
            <li>Your browser writes a request: a short message asking for that page.</li>
            <li>The request travels across the internet to the server that keeps the page.</li>
            <li>The server finds the page and puts it in a response.</li>
            <li>The response travels back across the internet.</li>
            <li>Your browser reads the response and draws the page on your screen.</li>
          </ol>
        </figure>
        <div>
          <p>The <span class="concept-1">request</span> is your browser asking: "Please send me the pancake page."</p>
          <p>The <span class="concept-2">response</span> is the server's answer, and it holds the page itself.</p>
        </div>
      </div>
      <p>Everything your browser shows arrives this way. Open a different page and your browser sends a new request and gets a new response, which can hold a photo, a video, or a song.</p>
      <div class="spots">
        <figure id="l1-photo"><svg viewBox="0 0 200 110" role="img" aria-label="A response holding a photo of a mountain."></svg><figcaption>A photo</figcaption></figure>
        <figure id="l1-video"><svg viewBox="0 0 200 110" role="img" aria-label="A response holding a video with a play symbol."></svg><figcaption>A video</figcaption></figure>
        <figure id="l1-song"><svg viewBox="0 0 200 110" role="img" aria-label="A response holding a song, shown as a music note."></svg><figcaption>A song</figcaption></figure>
      </div>
      <p class="recap">Your browser sends a <span class="concept-1">request</span>. A server sends back a <span class="concept-2">response</span>. Your browser shows you what's inside.</p>
    </section>
```

## Still drawings

The first call draws the title illustration, in the page's `<figure id="hero">`.

```js
const wood = 'var(--concept-4)', slip = 'var(--concept-2)', paper = 'var(--paper)', drawer = 'var(--fill)';

  function pancakes(shape, target, cx, ground) {
    [[ground - 8, 58], [ground - 18, 54], [ground - 28, 50]].forEach(([y, width]) => shape(target, 'ellipse', [cx, y, width, 15], { fill: wood }));
    shape(target, 'rectangle', [cx - 8, ground - 39, 15, 6], { fill: slip, speckle: 0 });
  }

  teachDrawing('#hero', ({ svg, shape, line, person, label }) => {
    person(svg, 62, 168, { reach: [112, 156] });
    shape(svg, 'rectangle', [118, 96, 84, 62], { fill: paper, speckle: 0 });
    shape(svg, 'rectangle', [108, 158, 104, 9], { fill: 'var(--muted)', hatch: { gap: 3 } });
    pancakes(shape, svg, 292, 168);
    shape(svg, 'ellipse', [172, 46, 104, 46], { fill: paper, speckle: 0 });
    line(svg, 118, 62, 94, 76);
    label(svg, 'Pancakes?', 172, 51);
    shape(svg, 'rectangle', [10, 167, 340, 10], { fill: wood });
  });

  teachDrawing('#l1-why', ({ svg, shape, line, label }) => {
    shape(svg, 'rectangle', [36, 66, 104, 84], { fill: paper, speckle: 0 });
    shape(svg, 'rectangle', [26, 150, 124, 9], { fill: 'var(--muted)', hatch: { gap: 3 } });
    line(svg, 152, 112, 238, 112, { stroke: 'var(--muted)', width: 1.5, dash: [5, 6] });
    shape(svg, 'rectangle', [246, 42, 92, 117], { fill: wood });
    [50, 86, 122].forEach((y, i) => shape(svg, 'rectangle', [254, y, 76, 29], { fill: i === 1 ? slip : drawer }));
    shape(svg, 'rectangle', [10, 159, 340, 10], { fill: wood });
    label(svg, 'Your computer', 88, 190);
    label(svg, 'A server', 292, 190);
  });

  function carried(selector, inside) {
    teachDrawing(selector, ({ svg, shape, line }) => {
      shape(svg, 'rectangle', [42, 6, 116, 98], { fill: slip });
      shape(svg, 'rectangle', [54, 18, 92, 74], { fill: paper, speckle: 0 });
      inside(shape, line, svg);
    });
  }
  carried('#l1-photo', (shape, line, svg) => {
    shape(svg, 'polygon', [[[60, 86], [86, 46], [104, 70], [116, 56], [140, 86]]], { fill: 'var(--concept-1)' });
    shape(svg, 'circle', [124, 36, 14], { fill: slip, speckle: 0 });
  });
  carried('#l1-video', (shape, line, svg) => {
    shape(svg, 'rectangle', [62, 28, 76, 50], { fill: 'var(--concept-3)' });
    shape(svg, 'polygon', [[[92, 42], [92, 64], [112, 53]]], { fill: paper, speckle: 0 });
  });
  carried('#l1-song', (shape, line, svg) => {
    shape(svg, 'ellipse', [88, 72, 20, 14], { fill: 'var(--ink)', speckle: 0 });
    shape(svg, 'ellipse', [120, 66, 20, 14], { fill: 'var(--ink)', speckle: 0 });
    line(svg, 97, 72, 97, 32, { width: 2.5 });
    line(svg, 129, 66, 129, 26, { width: 2.5 });
    line(svg, 97, 32, 129, 26, { width: 4 });
  });
```

## Animation

```js
teachScene('#scene-1', {
    draw({ shape, line, person }) {
      const request = 'var(--concept-1)', response = 'var(--concept-2)', wood = 'var(--concept-4)';
      const paper = 'var(--paper)', fill = 'var(--fill)';

      // You, reaching for the laptop.
      person('#l1-you', 54, 206, { reach: [100, 190] });

      // Laptop.
      shape('#l1-you', 'rectangle', [106, 76, 132, 114], { fill: paper, speckle: 0 });
      shape('#l1-you', 'rectangle', [114, 84, 116, 24], { fill, speckle: 0, stroke: 'none' });
      shape('#l1-you', 'rectangle', [94, 190, 156, 12], { fill: 'var(--muted)', hatch: { gap: 3 } });

      // The pancake page.
      [[140, 58], [150, 50], [160, 58], [170, 38]].forEach(([y, width]) => line('#l1-page-art', 116, y, 116 + width, y, { width: 1 }));
      [[172, 58], [162, 54], [152, 50]].forEach(([y, width]) => {
        shape('#l1-page-art', 'ellipse', [202, y, width, 15], { fill: wood });
      });
      shape('#l1-page-art', 'rectangle', [194, 143, 15, 6], { fill: response, speckle: 0 });

      // The internet: a globe above two lanes.
      shape('#l1-net', 'circle', [325, 84, 40], { fill: request });
      shape('#l1-net', 'ellipse', [325, 84, 18, 40], {});
      line('#l1-net', 305, 84, 345, 84);
      line('#l1-net', 256, 128, 392, 128, { stroke: request, width: 2, dash: [5, 6] });
      line('#l1-net', 382, 122, 393, 128, { stroke: request, width: 2 });
      line('#l1-net', 382, 134, 393, 128, { stroke: request, width: 2 });
      line('#l1-net', 256, 164, 392, 164, { stroke: response, width: 2, dash: [5, 6] });
      line('#l1-net', 266, 158, 255, 164, { stroke: response, width: 2 });
      line('#l1-net', 266, 170, 255, 164, { stroke: response, width: 2 });

      // Server cabinet with three drawers; the middle one lights up when the page is found.
      shape('#l1-server', 'rectangle', [400, 62, 130, 144], { fill: wood });
      shape('#l1-server', 'rectangle', [508, 62, 22, 144], { hatch: { gap: 4 }, stroke: 'none' });
      [70, 113, 156].forEach((y) => {
        shape('#l1-server', 'rectangle', [408, y, 94, 38], { fill });
        if (y === 113) {
          const found = shape('#l1-server', 'rectangle', [408, y, 94, 38], { fill: response });
          found.id = 'l1-found';
          found.setAttribute('opacity', 0);
        }
        shape('#l1-server', 'circle', [422, y + 19, 7], { fill: 'var(--ink)', speckle: 0, stroke: 'none' });
        line('#l1-server', 436, y + 19, 490, y + 19, { width: 2 });
      });

      // The two messages.
      shape('#l1-req-art', 'rectangle', [-44, -17, 88, 34], { fill: request });
      shape('#l1-res-art', 'rectangle', [-50, -17, 100, 34], { fill: response });

      // The shelf everything stands on.
      shape('#l1-ground', 'rectangle', [14, 202, 532, 11], { fill: wood });
      [[60, 200], [250, 380], [420, 520]].forEach(([from, to], i) => line('#l1-ground', from, 206 + (i % 2) * 3, to, 206 + (i % 2) * 3, { width: 0.8 }));

      gsap.set('#l1-req', { x: 172, y: 150 });
      gsap.set('#l1-res', { x: 344, y: 164 });
    },
    steps: [
      {
        focus: '.you',
        hold: 3.4,
        play: (tl, at) => tl
          .fromTo('#l1-typed-rect', { attr: { width: 0 } }, { attr: { width: 116 }, duration: 1.2, ease: 'steps(16)' }, at + 0.5)
          .to('#scene-1 .arm', { y: -3, duration: 0.15, repeat: 7, yoyo: true, ease: 'sine.inOut' }, at + 0.5),
      },
      {
        focus: '.you',
        hold: 3.8,
        play: (tl, at) => tl.to('#l1-req', { opacity: 1, duration: 0.5 }, at + 0.3),
      },
      {
        focus: '.net',
        hold: 3.6,
        play: (tl, at) => tl.to('#l1-req', { x: 455, y: 132, duration: 2.4, ease: 'power1.inOut' }, at),
      },
      {
        focus: '.server',
        hold: 3.6,
        play: (tl, at) => tl
          .to('#l1-req', { opacity: 0, duration: 0.5 }, at)
          .to('#l1-found', { opacity: 1, duration: 0.5 }, at)
          .to('#l1-res', { opacity: 1, duration: 0.5 }, at + 0.5),
      },
      {
        focus: '.net',
        hold: 3.4,
        play: (tl, at) => tl
          .to('#l1-found', { opacity: 0, duration: 0.5 }, at)
          .to('#l1-res', { x: 172, y: 164, duration: 2.4, ease: 'power1.inOut' }, at),
      },
      {
        focus: '.you',
        hold: 5,
        play: (tl, at) => tl
          .to('#l1-res', { opacity: 0, duration: 0.6 }, at)
          .to('#l1-page', { opacity: 1, duration: 0.7 }, at + 0.2),
      },
    ],
  });
```
