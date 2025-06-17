export class Canvas {
  constructor(ctx) {
    this.ctx = ctx;
    this.setCanvasDimensions();
  }

  setCanvasDimensions() {
    requestAnimationFrame(() => {
      const ctx = this.ctx;
      const canvas = ctx.canvas;
      const width = Number(canvas.getAttribute("width"));
      const height = Number(canvas.getAttribute("height"));
      const dpr = window.devicePixelRatio || 1;

      canvas.style.width = width + "px";
      canvas.style.height = height + "px";
      canvas.width = width * dpr;
      canvas.height = height * dpr;

      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.scale(dpr, dpr);
    });
  }

  clear() {
    requestAnimationFrame(() => {
      const ctx = this.ctx;
      const canvas = ctx.canvas;

      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      ctx.setTransform(1, 0, 0, 1, 0.5, 0.5);
    });
  }

  draw(commands) {
    requestAnimationFrame(() => {
      const ctx = this.ctx;

      ctx.beginPath();

      const firstCommand = commands[0];
      if (firstCommand && firstCommand.tag === "line") {
        // console.log("first command = ", firstCommand);

        ctx.moveTo(firstCommand.x1, firstCommand.y1);
      }

      commands.forEach((command) => {
        // console.log(command);

        switch (command.tag) {
          case "moveTo":
            ctx.moveTo(command.x, command.y);
            break;

          case "line":
            ctx.lineTo(command.x2, command.y2);
            break;

          default:
            console.error("Unknown command:", command);
        }
      });

      ctx.stroke();
    });
  }
}
