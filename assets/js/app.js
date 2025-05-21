import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import Hooks from "./hooks";
// import socket from "./user_socket.js";
import "./user_socket.js";

const basePath = process.env.NODE_ENV === "production" ? "/csci379-25s-y" : "";

let liveSocketPath = `${basePath}/live`;

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket(liveSocketPath, Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
window.liveSocket = liveSocket;
