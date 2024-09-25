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

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import ace from "../vendor/ace_editor/ace"

import "../vendor/ace_editor/theme-dracula"
import "../vendor/ace_editor/theme-eclipse"
import "../vendor/ace_editor/mode-c_cpp"
import "../vendor/ace_editor/mode-haskell"
import "../vendor/ace_editor/mode-markdown"
import "../vendor/ace_editor/ext-searchbox"

import Alpine from "alpinejs";
import collapse from "@alpinejs/collapse";

window.Alpine = Alpine;

Alpine.store('ace', ace);
Alpine.store('theme', getCurrentTheme());
Alpine.store('formatDateTime', (v) => {
  const dateUTC = new Date(v + "Z");
  return dateUTC.toLocaleString("sv-SE", {timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone})
});

Alpine.plugin(collapse);
Alpine.start();

import hljs from "highlight.js/lib/core";
import hljs_c from "highlight.js/lib/languages/c";
import hljs_haskell from "highlight.js/lib/languages/haskell";

hljs.registerLanguage('c', hljs_c);
hljs.registerLanguage('haskell', hljs_haskell);

let Hooks = {}

Hooks.MdEditor = {
  mounted() {
    var editor = ace.edit(this.el.id, {
      minLines: 3,
      maxLines: 20,
      wrap: "free",
      showLineNumbers: false,
      showPrintMargin: false,
      showGutter: false,
      highlightActiveLine: false,
    });
    if (getCurrentTheme() == "Light") { 
      editor.setTheme("ace/theme/eclipse");
    } else {
      editor.setTheme("ace/theme/dracula");
    }
    var cMode = ace.require("ace/mode/markdown").Mode;
    editor.session.setMode(new cMode());
    editor.session.on('change', function(delta) {
      document.getElementById("description-form").value = editor.getValue();
      document.getElementById(`description-form`).dispatchEvent(new Event('input', { bubbles: true }));
    });
  }
}

Hooks.Markdown = {
  mounted() {
    this.highlightCode();
  },
  updated() {
    this.highlightCode();
  },
  highlightCode() {
    this.el.querySelectorAll("pre code").forEach((block) => {
      hljs.highlightElement(block);
    });
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken}, 
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }
    }
  }
});

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

// document.querySelectorAll("time").forEach((el) => {
//   el.innerHTML = new Date(el.getAttribute("datetime")).toLocaleString("sv-SE", {timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone});
// })

window.addEventListener("phx:update-grade", (e) => {
  const target = document.getElementById(e.detail.target_id);
  const original = document.getElementById(e.detail.original_id); 

  if ("target_grade" in e.detail) {
    const grade = parseInt(e.detail.target_grade);
    if (grade >= 0 && grade <= 100) {
      target.value = grade;
      original.value = grade;
      target.dispatchEvent(new Event('input', { bubbles: true }));
    }
  }
  else {
    target.value = parseInt(original.value);
  }
})

window.addEventListener("phx:prompt_download", (e) => {
  let mimeType = null;
  switch (e.detail.filetype) {
    case "json":
      mimeType = "application/json";
      break;
    case "csv":
      mimeType = "text/csv";
      break;
    case _:
      mimeType = "text/plain";
  }

  const textContent = e.detail.content;
  const blob = new Blob([textContent], { type: mimeType });

  const element = document.createElement('a');
  element.setAttribute('href', URL.createObjectURL(blob));
  element.setAttribute('download', e.detail.filename + "." + e.detail.filetype);
  element.click();
  URL.revokeObjectURL(element.href);
})

// document.querySelectorAll(".md-text").forEach((el) => {
//   el.innerHTML = marked.parse(el.innerHTML);
// })