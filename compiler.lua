function compile(script_text)
    local lines = {}
    for line in script_text:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local instructions = {}
    local i = 1

    local function trim(s)
        return s:match("^%s*(.-)%s*$")
    end

    local function get_indent(line)
        local leading = line:match("^%s*")
        return #leading
    end

    while i <= #lines do
        local raw = lines[i]
        local l = trim(raw)

        -- Skip empty lines and comments
        if l == "" or l:sub(1,1) == ";" then
            i = i + 1
            goto continue
        end

        -- MENU BLOCK
        if l:match("^menu") then
            table.insert(instructions, { op = "MENU" })  -- << penting
            local menu_indent = get_indent(raw)
            i = i + 1

            while i <= #lines do
                local body_raw = lines[i]
                local body_l = trim(body_raw)
                local body_indent = get_indent(body_raw)

                -- End of menu when we dedent or hit a new top-level command
                if body_l == "" or body_l:sub(1,1) == ";" then
                    i = i + 1
                elseif body_indent <= menu_indent then
                    break
                elseif body_l:match("^bg%s+") then
                    local f = body_l:match("^bg%s+(%S+)")
                    table.insert(instructions, { op = "BG", a = f })
                    i = i + 1
                elseif body_l:match('^button%s+"') then
                    local text, rest = body_l:match('button%s+"(.-)"%s*(.*)')
                    local target = rest:match("goto%s+(%S+)") or ""
                    local is_exit = rest:find("exit") ~= nil
                    table.insert(instructions, {
                        op = "BUTTON",
                        a = text,
                        b = target,
                        exit_button = is_exit,
                    })
                    i = i + 1
                else
                    print("[COMPILER] Unknown inside menu:", body_l)
                    i = i + 1
                end
            end
            goto continue
        end

        -- Other top-level commands
        if l:match("^bg%s+") then
            local f = l:match("^bg%s+(%S+)")
            table.insert(instructions, { op = "BG", a = f })
        elseif l:match("^char%s+") then
            local name, file = l:match("^char%s+(%S+)%s+(%S+)")
            table.insert(instructions, { op = "CHAR", a = name, b = file })
        elseif l:match("^say%s+") then
            local speaker, text = l:match('say%s+(%S+)%s+"(.-)"')
            table.insert(instructions, { op = "SAY", a = speaker, b = text })
        elseif l:match("^narrate%s+") then
            local text = l:match('narrate%s+"(.-)"')
            table.insert(instructions, { op = "NARRATE", b = text })
        elseif l:match("^label%s+") then
            local name = l:match("^label%s+(%S+)")
            table.insert(instructions, { op = "LABEL", a = name })
        elseif l:match("^jump%s+") then
            local target = l:match("^jump%s+(%S+)")
            table.insert(instructions, { op = "JUMP", a = target })
        elseif l == "end" then
            table.insert(instructions, { op = "END" })
        else
            print("[COMPILER] Unknown top-level:", l)
        end

        i = i + 1
        ::continue::
    end

    return { instructions = instructions }
end
