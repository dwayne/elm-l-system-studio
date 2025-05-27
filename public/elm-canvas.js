export default class ElmCanvas extends HTMLElement {
  constructor () {
    super();

    const shadowRoot = this.attachShadow({ mode: "open" });
    shadowRoot.appendChild(template.content.cloneNode(true));

    this.canvas = shadowRoot.querySelector("canvas");
    this.context = this.canvas.getContext("2d");
    this.length = 0;
  }

  set commands (value) {
    // debugger
    // this.length += value.length;
    requestAnimationFrame(() => {
      this.render(value);
    });
  }

  connectedCallback () {
    // debugger
    requestAnimationFrame(() => {
      this.setCanvasDimensions();
    });
  }

  static observedAttributes = [ "width", "height" ];

  attributeChangedCallback (name, oldValue, newValue) {
    if ((name === "width" || name === "height") && (oldValue !== newValue)) {
      requestAnimationFrame(() => {
        this.setCanvasDimensions();
      });
    }
  }

  setCanvasDimensions () {
    const width = Number(this.getAttribute("width"));
    const height = Number(this.getAttribute("height"));

    const dpr = window.devicePixelRatio || 1;

    this.style.width = width + "px";
    this.style.height = height + "px";
    this.canvas.width = width * dpr;
    this.canvas.height = height * dpr;

    this.context.setTransform(1, 0, 0, 1, 0, 0);
    this.context.scale(dpr, dpr);
  }

  render (commands) {
    const context = this.context;

    console.log(commands);

    commands.forEach((command) => {
      switch (command.function) {
        case "moveTo":
          context.moveTo(command.x, command.y);
          break;

        case "lineTo":
          context.lineWidth = command.lineWidth;
          context.lineTo(command.x, command.y);
          context.stroke();
          break;

        default:
          console.log("Unknown command:", command);
      }
    });
  }
}

const template = document.createElement("template");
template.innerHTML = `
  <style>
    :host {
      display: block;
    }
  </style>
  <canvas><slot></slot></canvas>
`;
