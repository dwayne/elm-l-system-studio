# L-System Studio - [Live Demo](https://dwayne.github.io/elm-l-system-studio/)

An environment for creating and exploring L-Systems.

![A screenshot of L-System Studio](/screenshot.png)

## Table of Contents

- [Features](#features)
- [Backstory](#backstory)
- [Canvas performance](#canvas-performance)
- [Future improvements](#future-improvements)
- [Interesting future work](#interesting-future-work)
- [Usage](#usage)
- [Credits](#credits)

## Features

- 30+ presets
  - Including the Koch Curve, Quadratic Gosper, and Square Sierpinski
- Unlimited iterations
  - It uses lazy evaluation to generate, translate, and render L-Systems with ~~billions~~ ~~trillions~~ infinitely many symbols
- 2D camera
  - Supports an infinite canvas since you can position the camera anywhere you want
  - Supports panning horizontally and vertically
  - Supports zooming in and out
- Performant
  - Render 1,000,000 instructions per frame at 60 frames per second

## Backstory

When [hunorg/L-System-Studio](https://github.com/hunorg/L-System-Studio) was first submitted to [Built with Elm](https://www.builtwithelm.co/) I was excited to play with the application. However, my experience was tainted a bit because the application bogged down my browser when I tried rendering any of the interesting L-Systems for what I considered to be a very small number of iterations. Occassionally, the application would even fail completely. I also wasn't able to view the rendering properly since a 2D viewing pipeline wasn't available, i.e. world coordinates and canvavs coordinates coincided. I knew these shortcomings weren't inherent to Elm but rather to the way in which the application was built. These bad experiences prompted me to review the code and think about ways in which I could improve upon it.

> I don't want performance at the expense of sanity. I want to be able to express what's in my mind in a modular way while still being able to achieve reasonable performance.

My first foray into the code led to me improving the L-System generation which I wrote about in [Diary of an Elm Developer - Lazy L-System generation](https://dev.to/dwayne/diary-of-an-elm-developer-lazy-l-system-generation-2k7j) and [Diary of an Elm Developer - Improving Rules.lookup](https://dev.to/dwayne/diary-of-an-elm-developer-improving-ruleslookup-dni). These initial successes drew me further into the project until I was fully consumed by it.

L-System generation was solved but I wasn't 100% certain that it would lead to improvements in translation and rendering. In order for the performance to be improved, both translation and rendering needed to be done lazily as well.

Translation involved keeping track of the turtle's state. It took me a while to figure it out but in the end I was able to keep translation lazy. `Data.Translator.translate` uses `Lib.Sequence.filterMapWithState` to map and filter lazily over a sequence while threading state.

Rendering involved dropping SVG and drawing on an HTML5 canvas instead. Due to the potential of a generated L-System to require a billion+ SVG nodes I knew I needed to switch to HTML5 canvas for output. I never used canvas before so this requirement sent me on an interesting and fruitful journey where I learned about HTML5 canvas, `requestAnimationFrame`, web components, the difference between JavaScript attributes and properties, the 2D viewing pipeline, and so much more. I explored a variety of questions and scenarios in separate branches before settling on my final solution.

| Branch | Experiment |
|--------|------------|
| [svg-experiment](https://github.com/dwayne/elm-l-system-studio/tree/svg-experiment) | Is it really true that I can't use SVG? I ran into [a bug when rendering a certain number of SVG/HTML nodes](https://github.com/dwayne/elm-l-system-studio/commit/359da8905664875439c4529bf018e66a03a08bab). |
| [explore-using-a-web-component](https://github.com/dwayne/elm-l-system-studio/tree/explore-using-a-web-component) | Can I follow what [joakin/elm-canvas](https://github.com/joakin/elm-canvas) did and use a web component? As I tried to increase the amount of instructions I rendered per frame I saw artifacts in the drawing which showed that instructions were being skipped on the first frame. Maybe it was a timing issue but I wasn't able to resolve it. |
| [canvas-experiment](https://github.com/dwayne/elm-l-system-studio/commits/canvas-experiment/) | [Can I stream drawing commands to the canvas?](https://github.com/dwayne/elm-l-system-studio/commit/cbb7be64d464e47e9c37c81bf1c82fa742ed7580) Yes! The port solution is correct and performant. I can crank up the amount of instructions I render per frame and I see no visual anomalies. |

I settled on streaming drawing instructions via [ports](https://guide.elm-lang.org/interop/ports) to an HTML5 canvas.

The rest of the work wasn't specific to L-Systems so I won't go into that here.

## Canvas performance

These are some of the things I currently do to improve canvas performance:

- I [batch canvas calls together](https://web.dev/articles/canvas-performance#batch_canvas_calls_together)
  - If `frames per second (fps) = 30` and `instructions per frame (ipf) = 10` then `300 instructions per second (ips)` would be sent to the canvas to be drawn
  - Since I use `requestAnimationFrame` to coordinate the drawing it distributes that many instructions over the one second based on the time elapsed between calls to `requestAnimationFrame`
  - So in reality, if `0.5 seconds` elapsed between calls to `requestAnimationFrame` then `150 instructions` would be sent to the canvas over the port to be drawn as a single polyline
- I [clear the canvas](https://web.dev/articles/canvas-performance#know_various_ways_to_clear_the_canvas) using `ctx.clearRect(0, 0, width, height)`
- I [avoid floating point coordinates](https://web.dev/articles/canvas-performance#avoid_floating_point_coordinates)
  - World coordinates use floats but device (canvas) coordinates use integers, see [`Data.Transformer`](/src/Data/Transformer.elm)
- I [optimize my animations with `requestAnimationFrame`](https://web.dev/articles/canvas-performance#optimize_your_animations_with_requestanimationframe)

## Future improvements

The application is nowhere near complete but it satisfies my goals of being performant and allowing me to explore interesting L-Systems without having the browser crash on me. That said here are a few things that could be improved:

- The generated L-System string may have multiple forward movements one after the other
  - These can be combined into one forward movement of a larger length
  - Currently 10 consecutive forward movements would lead to 10 line drawing instructions
- When the view transformation is performed, multiple world coordinates get mapped to the same canvas coordinates in succession
  - The repeats can be removed
- Lines entirely outside the canvas can be skipped so as to avoid sending them over the port to the canvas only to be clipped by the canvas
- Drawing lines of even width, i.e. `lineWidth` is an even number, so that it looks good on the canvas
  - Currently, I use [this neat idea](https://stackoverflow.com/a/3279863/391924) to get my `1px` width lines to be drawn using `1px` without anti-aliasing effects
  - [How to draw very thin lines?](https://stackoverflow.com/questions/45114144/html-canvas-how-to-draw-very-thin-lines)
  - [HTML5 Canvas translate(0.5,0.5) not fixing line blurryness](https://stackoverflow.com/a/39951701/391924)
  - How can I generalize it to work for any line width?
- Add color support
- Design a nicer UI

## Interesting future work

I'm equally excited about the future work that this project generated for me as well.

- Extract an L-System rules and generator module, see [`Data.Rules`](/src/Data/Rules.elm) and [`Data.Generator`](/src/Data/Generator.elm)
- Extract a 2D camera module, see [`Data.Transformer`](/src/Data/Transformer.elm)
- Extract an animation timing module for regulating work to be done within a given number of frames per second, see [`Lib.Timer`](/src/Lib/Timer.elm) and [`Data.Renderer`](/src/Data/Renderer.elm)
- Explore using Taylor series expansion to calculate sine and cosine to arbitrary precision
- Explore [`Lib.Field`](/src/Lib/Field.elm)
  - It seems to be a promising abstraction upon which to base a form library

## Usage

This project is managed with [Devbox](https://www.jetify.com/devbox) and a few Bash scripts. Enter the development environment with `devbox shell`.

### Build

```bash
build-development # alias: b
build-production
```

### Serve

```bash
serve-development # alias: s
serve-production
```

### Deploy

```bash
deploy-production
```

### Format

```bash
format # alias: f
```

### Sanity checks

Individually:

```bash
check-scripts
test-elm # alias: t
test-elm-main
review   # alias: r
```

All at once:

```bash
check
```

## Credits

- [hunorg/L-System-Studio](https://github.com/hunorg/L-System-Studio) is the original application upon which this one is based
- Paul Bourke's [L-System User Notes](https://paulbourke.net/fractals/lsys/) contains useful information on L-Systems and a collection of examples that I used for my presets
- [YouTube: Why Functional Programming Matters by John Hughes at Functional Conf 2016](https://www.youtube.com/watch?v=XrNdvWqxBvA)
  - This video reminded me of the benefits of lazy evaluation and re-introduced me to the concept of [whole value programming](https://www.youtube.com/watch?v=XrNdvWqxBvA&t=1111s)
  - It played a major role in having me pursue improvements to the application through a lazy lens
- [Computer Graphics 2nd Edition](https://archive.org/details/computergraphics0000hear_r7z2) by Donald Hearn and Pauline M. Baker (1994)
  - "Chapter 6: Two-Dimensional Viewing" helped me learn how to set up a 2D viewing pipeline which led to the infinite canvas, panning, and zooming features
  - I learned how to go from world coordinates to viewing coordinates to normalized viewing coordinates to device (canvas) coordinates
- [MDN: Canvas tutorial](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial)
- [YouTube: Jake Archibald on the web browser event loop, setTimeout, micro tasks, requestAnimationFrame, ...](https://www.youtube.com/watch?v=cCOL7MC4Pl0)
