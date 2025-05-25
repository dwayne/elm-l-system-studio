// Q: Does an OffscreenCanvas speed things up even more?

export default class ElmCanvas extends HTMLElement {
  constructor () {
    super();

    const shadowRoot = this.attachShadow({ mode: "open" });
    shadowRoot.appendChild(template.content.cloneNode(true));

    this.canvas = shadowRoot.querySelector("canvas");
    this.context = this.canvas.getContext("2d");
    this._commands = [];
  }

  set commands (value) {
    this._commands = value;
    requestAnimationFrame(() => {
      this.render();
    });
  }

  connectedCallback () {
    requestAnimationFrame(() => {
      this.setCanvasDimensions();
      this.render();
    });
  }

  static observedAttributes = [ "width", "height" ];

  attributeChangedCallback (name, oldValue, newValue) {
    if ((name === "width" || name === "height") && (oldValue !== newValue)) {
      requestAnimationFrame(() => {
        this.setCanvasDimensions();
        this.render();
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

  render () {
    const commands = this._commands;

    this.context.beginPath();

    commands.forEach(({ x1, y1, x2, y2 }) => {
      this.context.moveTo(x1, y1);
      this.context.lineTo(x2, y2);
    });

    this.context.stroke();
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
