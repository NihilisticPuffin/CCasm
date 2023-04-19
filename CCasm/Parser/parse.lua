local switch = require "CCasm.util.switch"
local lex = require "CCasm.Lexer.lex"
local instructions, keywords = require "CCasm.util.consts" ()


function parse(tokens, error_reporter)
    function sub_parse(tokens)
        local tmp = register['ip']
        register['ip'] = 1
        parse( tokens )
        register['ip'] = tmp
    end

    local function rev(t)
        local r = {}
        for i = #t, 1, -1 do
            r[#r+1] = t[i]
        end
        return r
    end

    local function printt(tbl)
        print(textutils.serialize(tbl))
    end

    local function isRegister(...)
        for index, value in pairs(arg) do
            if index == 'n' then return end
            if register[value] == nil then return false end
            return true
        end
    end

    local function assertRegister(...)
        for index, value in pairs(arg) do
            if index == 'n' then return end
            assert(isRegister(value) == true, value .. " is not a register")
        end
    end

    local function advance()
        register['ip'] = register['ip'] + 1
        return tokens[register['ip'] - 1]
    end

    for i, v in ipairs(tokens) do
        if v.type == 'LABEL' then
            labels[v.lexeme] = i
        end
    end

    function jmp_line(line)
        for k, v in ipairs(tokens) do
            if v.line == line then
                register['ip'] = k
                break
            end
        end
    end


    while register['ip'] <= #tokens do
        local i = advance()
        if i.type == instructions['set'] then
            local reg = advance()
            assertRegister(reg.lexeme)
            local val = advance()
            register[reg.lexeme] = val.literal
        elseif i.type == instructions['mov'] then
            local reg_a = advance()
            local reg_b = advance()
            assertRegister(reg_a.lexeme, reg_b.lexeme)
            register[reg_b.lexeme] = register[reg_a.lexeme]
        elseif i.type == instructions['psh'] then
            local val = advance()
            if not val.type == 'NUMBER' then error("[Line: " .. i.line  .. "] Instruction " .. i.type .. " expects type of number", 0) end
            table.insert(stack, val.literal)
        elseif i.type == instructions['pop'] then
            table.remove(stack)
        elseif i.type == instructions['str'] then
            local reg = advance()
            assertRegister(reg.lexeme)
            table.insert(stack, register[reg.lexeme])
        elseif i.type == instructions['ldr'] then
            local reg = advance()
            assertRegister(reg.lexeme)
            register[reg.lexeme] = table.remove(stack)
        elseif i.type == instructions['add'] then
            local b = table.remove(stack)
            local a = table.remove(stack)
            table.insert(stack, a + b)
        elseif i.type == instructions['sub'] then
            local b = table.remove(stack)
            local a = table.remove(stack)
            table.insert(stack, a - b)
        elseif i.type == instructions['mul'] then
            local b = table.remove(stack)
            local a = table.remove(stack)
            table.insert(stack, a * b)
        elseif i.type == instructions['div'] then
            local b = table.remove(stack)
            local a = table.remove(stack)
            table.insert(stack, a / b)
        elseif i.type == instructions['mod'] then
            local b = table.remove(stack)
            local a = table.remove(stack)
            table.insert(stack, a % b)
        elseif i.type == instructions['cmp'] then
            local reg = advance()
            local val = advance()
            assertRegister(reg.lexeme)
            if isRegister(val.lexeme) then
                table.insert(stack, register[val.lexeme] == register[reg.lexeme] and 1 or 0)
            elseif val.type == 'NUMBER' then
                table.insert(stack, val.literal == register[reg.lexeme] and 1 or 0)
            else
                error("[Line: " .. i.line  .. "] Instruction " .. i.type .. " expects type of register or number", 0)
            end
        elseif i.type == instructions['jmp'] then
            local val = advance()
            if isRegister(val.lexeme) then
                jmp_line(register[val.lexeme])
            elseif labels[val.lexeme] then
                register['ip'] = labels[val.lexeme]
            elseif val.type == 'NUMBER' then
                jmp_line(val.literal)
            else
                error("[Line: " .. i.line  .. "] Instruction " .. i.type .. " expects type of register, number, or label", 0)
            end
        elseif i.type == instructions['jeq'] then
            local val = advance()
            if table.remove(stack) ~= 0 then
                if isRegister(val.lexeme) then
                    jmp_line(register[val.lexeme])
                elseif labels[val.lexeme] then
                    register['ip'] = labels[val.lexeme]
                elseif val.type == 'NUMBER' then
                    jmp_line(val.literal)
                else
                    error("[Line: " .. i.line  .. "] Instruction " .. i.type .. " expects type of register, number, or label", 0)
                end
            end
        elseif i.type == instructions['jne'] then
            local val = advance()
            if table.remove(stack) == 0 then
                if isRegister(val.lexeme) then
                    jmp_line(register[val.lexeme])
                elseif labels[val.lexeme] then
                    register['ip'] = labels[val.lexeme] + 1
                elseif val.type == 'NUMBER' then
                    jmp_line(val.literal)
                else
                    error("[Line: " .. i.line  .. "] Instruction " .. i.type .. " expects type of register, number, or label", 0)
                end
            end
        elseif i.type == instructions['slp'] then
            local val = advance()
            if isRegister(val.lexeme) then
                sleep(register[val.lexeme])
            elseif val.type == 'NUMBER' then
                sleep(val.literal)
            else
                error("[Line: " .. i.line  .. "] Instruction " .. i.type .. " expects type of register or number", 0)
            end
        elseif i.type == instructions['utc'] then
            local reg = advance()
            assertRegister(reg.lexeme)
            register[reg.lexeme] = os.epoch('utc')
        elseif i.type == instructions['chr'] then
            local val = advance()
            if isRegister(val.lexeme) then
                write(string.char(register[val.lexeme]))
            elseif val.type == 'NUMBER' then
                write(string.char(val.literal))
            else
                error("[Line: " .. i.line  .. "] Instruction " .. i.type .. " expects type of register or number", 0)
            end
        elseif i.type == instructions['out'] then
            local val = advance()
            if isRegister(val.lexeme) then
                write(register[val.lexeme])
            elseif val.type == 'NUMBER' then
                write(val.literal)
            else
                error("[Line: " .. i.line  .. "] Instruction " .. i.type .. " expects type of register or number", 0)
            end
        elseif i.type == instructions['dmp'] then
            printt( rev(stack) )
        elseif i.type == instructions['imp'] then
            local file = advance()
            if file.type ~= 'STRING' then error("[Line: " .. i.line  .. "] Instruction " .. i.type .. " expects type of string", 0) end
            if fs.isDir(file.literal) or not fs.exists(file.literal) then error("[Line: " .. i.line  .. "] Could not import file " .. file.literal) end
            local h = fs.open(file.literal, 'r')
            local code = h.readAll()
            h.close()
            sub_parse(lex(code, error_reporter))
        elseif i.type == instructions['hlt'] then
            break
        elseif i.type == 'LABEL' then
        elseif i.type == 'START' then
            local name = advance()

            local body = {}
            local t = advance()
            while t.type ~= 'END' do
                table.insert(body, t)
                t = advance()
            end
            macros[name.lexeme] = body
        elseif i.type == 'MACRO' then
            if not macros[i.lexeme] then error("[Line: " .. i.line  .. "] Undefined macro " .. i.lexeme, 0) end
            sub_parse( macros[i.lexeme] )
        else
            error("[Line: " .. i.line  .. "] Unexpected " .. i.type .. " " .. i.lexeme, 0)
        end
    end
end

return parse