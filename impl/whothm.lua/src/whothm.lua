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


DEBUG_SCAN = false

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
        -- debug("set_token " .. text .. " (" .. type .. ")")
    end

    methods.scan = function()
        methods.scan_impl()
        if DEBUG_SCAN then
            print("scanned '" .. _text .. "' (" .. _type .. ")")
        end
        return _text
    end

    methods.scan_impl = function()
        -- discard leading whitespace
        while isspace(string:sub(1,1)) and string ~= "" do
            string = string:sub(2)
            -- TODO: count pos and line
        end
        
        if string == "" then
            methods.set_token("EOF", "EOF")
            return
        end

        -- check for any single character tokens
        local c = string:sub(1,1)
        if issep(c) then
            string = string:sub(2)
            methods.set_token(c, "seperator")
            return
        end

        -- check for arguments
        if string:sub(1,1) == "#" then
            local len = 0
            while isdigit(string:sub(2+len,2+len)) and len <= string:len() do
                len = len + 1
            end
            if len > 0 then
               local argnum = string:sub(2, 2+len-1)
               string = string:sub(2+len)
               methods.set_token(argnum, "arg")
               return
            end
        end

        -- check for strings of "word" characters
        if isalnum(string:sub(1,1)) then
            local len = 0
            while isalnum(string:sub(1+len,1+len)) and len <= string:len() do
                len = len + 1
            end
            local word = string:sub(1, 1+len-1)
            string = string:sub(1+len)
            methods.set_token(word, "ident")
            return
        end

        debug("scanner couldn't scan '" .. string .. "'")

        methods.set_token('UNKNOWN', 'UNKNOWN')
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
            raise_VeloSyntaxError("expected '" .. s ..
                                  "', found '" .. _text .. "'")
        end
    end

    debug("created scanner with string '" .. string .. "'")
    methods.scan()

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

    -- init
    scanner.scan()

    return methods
end
