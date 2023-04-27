// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

import EasyMDE from "easymde";
import "easymde/dist/easymde.min.css";
import "codemirror/theme/dracula.css";
import "codemirror/theme/eclipse.css";

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import ace from "../vendor/ace_editor/ace"

import "../vendor/ace_editor/theme-dracula"
import "../vendor/ace_editor/mode-c_cpp"

// window.addEventListener(`phx:get_code`, (e) => {
//     document.getElementById("editor_code").value = editor.getValue();
// })

function start_editor(editor_id) {
  var editor = ace.edit(editor_id);
  editor.setTheme("ace/theme/dracula");
  var cMode = ace.require("ace/mode/c_cpp").Mode;
  editor.session.setMode(new cMode());
  return editor;
}

let Hooks = {}

Hooks.Editor = {
  mounted() {
    let editor_id = this.el.id;
    let editor = start_editor(editor_id);
    document.getElementById(`${editor_id}-loading`).style.display = "none";
    document.getElementById(`${editor_id}-code`).value = editor.getValue();
    editor.session.on('change', function(delta) {
        // delta.start, delta.end, delta.lines, delta.action
        // document.getElementById("submit_button").disabled = true;
        document.getElementById(`${editor_id}-code`).value = editor.getValue();
        // document.getElementById("submit_button").disabled = false;
    });
  }
}

Hooks.EditorReadOnly = {
  mounted() {
    let editor = start_editor(this.el.id);
    editor.setReadOnly(true);
  }
}

Hooks.TestButton = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      this.pushEvent("pre_test_code")
      this.pushEvent("test_code", {"code": ace.edit("editor").getValue()})
    })
  }
}

Hooks.MdEditor = {
  mounted() {
    let theme = "dracula";
    if (getCurrentTheme() == "Light") { theme = "eclipse"; }
    let easyMDE = new EasyMDE({element: this.el, status: false, spellChecker: false, sideBySideFullscreen: false, toolbar: ["bold", "italic", "heading", "|", "code", "quote", "unordered-list", "ordered-list", "|", "link", "image", "table", "|", "preview", "side-by-side", "|", "guide"], theme: theme });
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})

let topBarScheduled = undefined;
window.addEventListener("phx:page-loading-start", () => {
  if(!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 500);
  };
});
window.addEventListener("phx:page-loading-stop", () => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  topbar.hide();
});

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

function getCurrentTheme() {
  if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    return "Dark";
  } else {
    return "Light";
  }
}

document.querySelectorAll(".datetime").forEach((el) => {
  el.innerHTML = new Date(el.getAttribute("datetime")).toLocaleString("sv-SE", {timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone});
})

// document.querySelectorAll(".md-text").forEach((el) => {
//   el.innerHTML = marked.parse(el.innerHTML);
// })