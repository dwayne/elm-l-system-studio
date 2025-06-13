import { Canvas } from "./canvas.js";

const app = Elm.Main.init({
  node: document.getElementById("app")
});
const ctx = document.getElementById("canvas").getContext("2d");
const canvas = new Canvas(ctx);

app.ports.clear.subscribe(() => {
  canvas.clear();
});

app.ports.draw.subscribe((commands) => {
  canvas.draw(commands);
});
