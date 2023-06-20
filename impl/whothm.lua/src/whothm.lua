--
-- whothm.lua
--

table = require "table"


TruthTable = {}
TruthTable.new = function()
    local tt = {}
    local methods = {}

    methods.map_to_true = function(truth_pair)
        tt[truth_pair] = true
    end

    methods.apply = function(a, b)
        local t1
        if a then t1 = "T" else t1 = "F" end
        local t2
        if b then t2 = "T" else t2 = "F" end
        return tt[t1 .. t2] or false
    end

    methods.to_s = function()
        local text = "TruthTable(\n"
        for key,value in pairs(tt) do
           text = text .. "  " .. key .. " => T,\n"
        end
        return text .. ")"
    end

    return methods
end


Rectangle = {}
Rectangle.new = function(x, y, w, h)
    local data = {
        ["x"] = x,
        ["y"] = y,
        ["w"] = w,
        ["h"] = h
    }
    local methods = {}

    methods.get_property = function(name)
        return data[name]
    end

    methods.change_property = function(name, delta)
        data[name] = data[name] + delta
    end

    methods.draw = function(bitmap, tt)
        local b_w = bitmap.get_width()
        local b_h = bitmap.get_height()

        if x > b_w and x+w > b_w and y > b_h and y+h > b_h then
            return
        end
        local right = x + w
        if right > b_w then right = b_w end
        local bottom = y + h
        if bottom > b_h then bottom = b_h end

        local px, py
        for py = y,bottom do
            for px = x,right do
                bitmap.modify_pixel(px, py, tt)
            end
        end
    end

    methods.to_s = function()
        return "Rectangle(" .. x .. "," .. y .. "," .. w .. "," .. h .. ")"
    end

    return methods
end


BitMap = {}
BitMap.new = function(width, height)
    local methods = {}
    local data

    methods.clear = function()
        local i
        data = {}
        for i=1, width * height do
            data[i] = false
        end
    end

    methods.get_height = function() return height end
    methods.get_width = function() return width end

    methods.alter_width = function(delta)
        local new_width = width + delta
        if new_width < 1 then new_width = 1 end
        width = new_width
        methods.clear()
    end

    methods.alter_height = function(delta)
        local new_height = height + delta
        if new_height < 1 then new_height = 1 end
        height = new_height
        methods.clear()
    end

    methods.get_pixel = function(x, y)
        local pos = y * width + x
        return data[pos]
    end

    methods.modify_pixel = function(x, y, tt)
        local pos = y * width + x
        if x < width and y < height then
            data[pos] = tt.apply(data[pos], true)
        end
    end

    methods.render_to_text = function()
        local buffer = {}
        local px, py
        local c
        for py = 1,height do
            for px = 1,width do
                if methods.get_pixel(px, py) then
                    table.insert(buffer, "*")
                else
                    table.insert(buffer, " ")
                end
            end
            table.insert(buffer, "\n")
        end
        return table.concat(buffer)
    end

    -- init
    methods.clear()

    return methods
end

--[[ ============ SCANNER SUPPORT ============ ]]--

DEBUG = false
function debug(s)
    if DEBUG then print(s) end
end

function isdigit(s)
    return string.find("0123456789", s, 1, true) ~= nil
end

function islower(s)
    return string.find("abcdefghijklmnopqrstuvwxyz", s, 1, true) ~= nil
end

function isupper(s)
    return string.find("ABCDEFGHIJKLMNOPQRSTUVWXYZ", s, 1, true) ~= nil
end

function isalpha(s)
    return islower(s) or isupper(s)
end

function isalnum(s)
    return isalpha(s) or isdigit(s)
end

function issep(s)
    return string.find("(),.;=", s, 1, true) ~= nil
end

function isspace(s)
    return string.find(" \t\n\r", s, 1, true) ~= nil
end

function iseol(s)
    return string.find("\n\r", s, 1, true) ~= nil
end

--[[ ========== SCANNER ========== ]]--

Scanner = {}
Scanner.new = function(s)
    local string = s
    local _text = nil
    local _type = nil

    local methods = {}

    methods.text = function() return _text end
    methods.type = function() return _type end

    methods.is_eof = function()
        return _type == "EOF"
    end

    methods.set_token = function(text, type)
        _text = text
        _type = type
        debug("set_token " .. text .. " (" .. type .. ")")
    end

    methods.scan = function()
        methods.scan_impl()
        debug("scanned '" .. _text .. "' (" .. _type .. ")")
        return _text
    end

    methods.scan_impl = function()
        -- discard leading whitespace
        while isspace(string:sub(1,1)) and string ~= "" do
            string = string:sub(2)
            -- TODO: count pos and line
        end

        -- check for end of input
        if string == "" then
            methods.set_token("EOF", "EOF")
            return
        end

        -- else check for identifiers
        if isalpha(string:sub(1,1)) then
            local len = 0
            while isalpha(string:sub(1+len,1+len)) and len <= string:len() do
                len = len + 1
            end
            local word = string:sub(1, 1+len-1)
            string = string:sub(1+len)
            methods.set_token(word, "ident")
            return
        end

        -- else check for literal decimal number
        if string:sub(1,1) == "-" or isdigit(string:sub(1,1)) then
            local len = 0
            if string:sub(1,1) == "-" then
                len = len + 1
            end
            while isdigit(string:sub(1+len,1+len)) and len <= string:len() do
                len = len + 1
            end
            methods.set_token(string:sub(1, len), "numlit")
            string = string:sub(len + 1)
            return
        end

        -- else check for certain two-character tokens
        local c = string:sub(1,2)
        if c == "+=" or c == ":=" then
            string = string:sub(3)
            methods.set_token(c, "operator")
            return
        end

        -- anything else => one character token
        local c = string:sub(1,1)
        string = string:sub(2)
        methods.set_token(c, "operator")
    end

    methods.consume = function(s)
        if _text == s then
            methods.scan()
            return true
        else
            return false
        end
    end

    methods.consume_type = function(t)
        if _type == t then
            methods.scan()
            return true
        else
            return false
        end
    end

    methods.expect = function(s)
        if _text == s then
            methods.scan()
        else
            error(
                "expected '" .. s ..
                "', found '" .. _text .. "'"
            )
        end
    end

    debug("created scanner with string '" .. string .. "'")

    return methods
end


render_table = function(t)
    local s = "{"
    for key,value in pairs(t) do
        if type(value) == "table" then
            s = s .. key .. ": " .. render_table(value) .. ","
        else
            s = s .. key .. ": " .. tostring(value) .. ","
        end
    end
    return s .. "}"
end


Machine = {}
Machine.new = function()
    local methods = {}
    local bitmap = nil
    local commands = {}

    methods.add_draw_command = function(rect, tt)
        local command = {}
        command.type = "draw"
        command.rect = rect
        command.tt = tt
        table.insert(commands, command)
    end

    methods.add_delta_command = function(rect, property, delta)
        local command = {}
        command.type = "delta"
        command.rect = rect
        command.property = property
        command.delta = delta
        table.insert(commands, command)
    end

    methods.add_delta_indirect_command = function(rect, property, src_rect, src_property)
        local command = {}
        command.type = "delta_indirect"
        command.rect = rect
        command.property = property
        command.src_rect = rect
        command.src_property = property
        table.insert(commands, command)
    end

    methods.execute = function(command)
        if command.type == "draw" then
            command.rect.draw(bitmap, command.tt)
        elseif command.type == "delta" then
            command.rect.change_property(command.property, command.delta)
        elseif command.type == "delta_indirect" then
            local delta = command.src_rect.get_property(src_property)
            command.dest_rect.change_property(command.dest_property, delta)
        else
            error("Malformed command: " .. render_table(command))
        end
    end

    methods.run = function(given_bitmap)
        bitmap = given_bitmap
        for i = 0,100 do
            for key,command in pairs(commands) do
                methods.execute(command)
            end
        end
    end

    methods.dump_state = function()
        for key,value in pairs(commands) do
            print(key, render_table(value))
        end
    end

    return methods
end


Parser = {}
Parser.new = function(source)
    local methods = {}
    local line = 1
    local pos = 0
    local token
    local rect_map = {}
    local tt_map = {}
    local m  -- machine
    local scanner = Scanner.new(source)

    local token_is = function(s) return s == scanner.text() end

    methods.parse = function()
        m = Machine.new()
        while not token_is("begin") do
            methods.parse_decl()
            scanner.expect(";")
        end
        scanner.expect("begin")
        while not token_is("end") do
            methods.parse_command()
            scanner.expect(";")
        end
        scanner.expect("end")
        return m
    end

    methods.parse_decl = function()
        local name = scanner.text()
        scanner.scan()
        scanner.expect(":=")
        if scanner.consume("(") then
            -- it's a rectangle
            local x = tonumber(scanner.text())
            scanner.scan()
            scanner.expect(",")
            local y = tonumber(scanner.text())
            scanner.scan()
            scanner.expect(",")
            local w = tonumber(scanner.text())
            scanner.scan()
            scanner.expect(",")
            local h = tonumber(scanner.text())
            scanner.scan()
            scanner.expect(")")
            rect_map[name] = Rectangle.new(x, y, w, h)
        else
            -- it's a truthtable
            local tt = TruthTable.new()
            local truth_pair = scanner.text()
            scanner.scan()
            tt.map_to_true(truth_pair)
            while scanner.consume("/") do
                truth_pair = scanner.text()
                scanner.scan()
                tt.map_to_true(truth_pair)
            end
            tt_map[name] = tt
        end
    end

    methods.parse_command = function()
        if scanner.consume("draw") then
            -- it's a draw command
            local rect = methods.parse_rect()
            scanner.expect(",")
            local tt_name = scanner.text()
            scanner.scan()
            local tt = tt_map[tt_name]
            if tt == nil then
                -- throw new ParseException(line, "Undefined truth table '" + ttName + "'");
                print("Undefined truth table") -- FIXME accumulate error
            else
                m.add_draw_command(rect, tt)
            end
        else
            -- it's a delta command
            local rect = methods.parse_rect()
            scanner.expect(".")
            local property = scanner.text()
            scanner.scan()
            scanner.expect("+=")
            if scanner.type() == "numlit" then
                local value = tonumber(scanner.text())
                scanner.scan()
                m.add_delta_command(rect, property, value)
            else
                local src_rect = methods.parse_rect()
                scanner.expect(".")
                local src_property = scanner.text()
                scanner.scan()
                m.add_delta_indirect_command(rect, property, src_rect, src_property)
            end
        end
    end

    methods.parse_rect = function()
        local name = scanner.text()
        scanner.scan()
        local rect = rect_map[name]
        if rect == nil then
            -- throw new ParseException(line, "Undefined rectangle '" + rectName + "'");
            print("Undefined rectangle")
        end
        return rect
    end

    methods.dump_state = function()
        for key,value in pairs(rect_map) do
            print(key, value.to_s())
         end
         for key,value in pairs(tt_map) do
            print(key, value.to_s())
         end
    end

    -- init
    scanner.scan()

    return methods
end
