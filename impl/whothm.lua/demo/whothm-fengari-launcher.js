/*
 * fengari-web.js and whothm.lua must be loaded before this source.
 * After loading this source, call launch() to create and start the interpreter.
 */

function launch(config) {
  config.container.innerHTML = `
    <canvas id="canvas" style="border: 1px solid black; float: right" width=400 height=400></canvas>
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
  examplePrograms = [{
    filename: "hello-world.whothm",
    contents: `r := (0, 0, 1, 2);
s := (0, 0, 1, 2);
XOR := TF/FT;

begin
r.x += r.w;
r.x += -1;
r.w += 1;
r.h += 1;
draw r, XOR;
s.x += s.w;
s.x += -1;
s.w += 1;
s.h += 2;
draw s, XOR;
end`
    }
  ];
  var select = makeSelect(controlPanel, "example program:", examplePrograms, function(option) {
    document.getElementById('editor').value = option.contents;
  });
  selectOptionByText(select, "hello-world.whothm");
}

function setLuaGlobal(name, value) {
  fengari.interop.push(fengari.L, value);
  fengari.lua.lua_setglobal(fengari.L, name);
}

function run() {
  // set up print function
  var outputElem = document.getElementById("output");
  outputElem.innerHTML = '';
  setLuaGlobal("print", function() {
    var s = fengari.interop.tojs(fengari.L, 2);
    outputElem.innerHTML += s + "\n";
  });

  // set up canvas drawing
  var canvas = document.getElementById("canvas");
  setLuaGlobal("set_color", function() {
    var r = fengari.interop.tojs(fengari.L, 2);
    var g = fengari.interop.tojs(fengari.L, 3);
    var b = fengari.interop.tojs(fengari.L, 4);
    console.log("set_color", r, g, b)
  });
  setLuaGlobal("fill_rect", function() {
    var x = fengari.interop.tojs(fengari.L, 2);
    var y = fengari.interop.tojs(fengari.L, 3);
    var w = fengari.interop.tojs(fengari.L, 4);
    var h = fengari.interop.tojs(fengari.L, 5);
    console.log("fill_rect", x, y, w, h)
  });

  // set whothm program
  var progText = document.getElementById("editor").value;
  setLuaGlobal("whothm_prog", progText);

  // run whothm program
  fengari.load(`
    local parser = Parser.new(whothm_prog)
    local machine = parser.parse()
    -- print(machine.to_s())
    local r = Rectangle.new(5, 1, 6, 10)
    local b = BitMap.new(40, 20)
    local t = TruthTable.new()
    t.map_to_true("FT")
    t.map_to_true("TF")
    r.draw(b, t)
    print(b.render_to_text())
    b.render_to_canvas(set_color, fill_rect, 5, 5)
  `)();
}
