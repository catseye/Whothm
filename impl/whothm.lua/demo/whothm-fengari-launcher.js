/*
 * fengari-web.js and whothm.lua must be loaded before this source.
 * After loading this source, call launch() to create and start the interpreter.
 */

function launch(config) {
  config.container.innerHTML = `
    <textarea id="editor" rows="10" cols="80"></textarea>
    <div id="control-panel"></div>
    <button onclick="run()">Run</button>
    <pre id="output"></pre>
  `;

  function makeSelect(container, labelText, optionsArray, fun) {
    var label = document.createElement('label');
    label.innerHTML = labelText;
    container.appendChild(label);
    var select = document.createElement("select");
    for (var i = 0; i < optionsArray.length; i++) {
      var op = document.createElement("option");
      op.text = optionsArray[i].filename;
      op.value = optionsArray[i].contents;
      select.options.add(op);
    }
    select.onchange = function(e) {
      fun(optionsArray[select.selectedIndex]);
    };
    select.selectedIndex = 0;
    label.appendChild(select);
    return select;
  };

  function selectOptionByText(selectElem, text) {
    var optElem;
    for (var i = 0; optElem = selectElem.options[i]; i++) {
      if (optElem.text === text) {
        selectElem.selectedIndex = i;
        selectElem.dispatchEvent(new Event('change'));
        return;
      }
    }
  }

  var controlPanel = document.getElementById('control-panel');
  /*
  var select = makeSelect(controlPanel, "example program:", examplePrograms, function(option) {
    document.getElementById('editor').value = option.contents;
  });
  selectOptionByText(select, "hello-world.velo");
  */
}

function setUpPrint(elem) {
  elem.innerHTML = '';
  fengari.interop.push(fengari.L, function() {
    var s = fengari.interop.tojs(fengari.L, 2);
    elem.innerHTML += s + "\n";
  });
  fengari.lua.lua_setglobal(fengari.L, "whothmPrint");
}

function loadWhothmProg(progText) {
  fengari.interop.push(fengari.L, progText);
  fengari.lua.lua_setglobal(fengari.L, "whothm_prog");
}

function runWhothmProg() {
  var luaProg = `
    local parser = Parser.new(whothm_prog)
    local machine = parser.parse()
    whothmPrint(machine.to_s())
  `;

  fengari.load(luaProg)();
}

function run() {
  setUpPrint(document.getElementById("output"));
  loadWhothmProg(document.getElementById("editor").value);
  runWhothmProg();
}
