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

window.Alpine = Alpine;

// window.addEventListener(`phx:get_code`, (e) => {
//     document.getElementById("editor_code").value = editor.getValue();
// })

Alpine.store('ace', ace);
Alpine.store('theme', getCurrentTheme());
Alpine.store('formatDateTime', (v) => (new Date(v).toLocaleString("sv-SE", {timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone})));

Alpine.start();

function initEditor(editor_id, language) {
  const editor = ace.edit(editor_id, {
    maxLines: 20,
  });
  if (getCurrentTheme() == "Light") { 
    editor.setTheme("ace/theme/eclipse");
  } else {
    editor.setTheme("ace/theme/dracula");
  }
  set_language(editor, language);
  return editor;
}

function set_language(editor, language) {
  switch (language) {
    case "c":
      editor.session.setMode("ace/mode/c_cpp");
      break;
    case "haskell":
      editor.session.setMode("ace/mode/haskell");
      break;
  }
}

let Hooks = {}

Hooks.EditorReadOnly = {
  mounted() {
    const editor = initEditor(this.el.id);
    set_language(editor, this.el.getAttribute("data-language"));
    editor.setOptions({readOnly: true, minLines: 6, highlightActiveLine: false, highlightGutterLine: false});
    editor.renderer.$cursorLayer.element.style.display = "none"
    this.handleEvent("expand_editor", (data) => {
      if(data.expand == "true")
        editor.setOptions({minLines: 20, maxLines: 100});
      else
        editor.setOptions({minLines: 6, maxLines: 20});
    })
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
    // let theme = "dracula";
    // if (getCurrentTheme() == "Light") { theme = "eclipse"; }
    // let easyMDE = new EasyMDE({element: this.el, status: false, spellChecker: false, sideBySideFullscreen: false, toolbar: ["bold", "italic", "heading", "|", "code", "quote", "unordered-list", "ordered-list", "|", "link", "image", "table", "|", "preview", "side-by-side", "|", "guide"], theme: theme });
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

// document.querySelectorAll(".md-text").forEach((el) => {
//   el.innerHTML = marked.parse(el.innerHTML);
// })