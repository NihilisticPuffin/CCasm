local switch = require "CCasm.util.switch"
local lex = require "CCasm.Lexer.lex"
local Token = require "CCasm.Lexer.Token"
local instructions, keywords = require "CCasm.util.consts" ()

local nest = {}

function parse(tokens)
    local function sub_parse(tokens)
        table.insert(nest, register['ip'])
        register['ip'] = 1
        parse( tokens )
        register['ip'] = table.remove(nest)
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

    local function peek()
        return tokens[register['ip']]
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

    local function jmp_line(line)
        if line > tokens[#tokens].line then
            report(line, "Jump out of bounds")
        end
        for k, v in ipairs(tokens) do
            if v.line == line then
                register['ip'] = k
                break
            end
        end
    end

    local function handle_jump(i, val)
        if isRegister(val.lexeme) then
            if type(register[val.lexeme]) == 'table' then
                if register[val.lexeme].type == 'NULL' then report(i.line, "Cannot jump to NULL") end
            end
            jmp_line(register[val.lexeme])
        elseif labels[val.lexeme] then
            register['ip'] = labels[val.lexeme]
        elseif val.type == 'NUMBER' then
            jmp_line(val.literal)
        else
            report(i.line, "Instruction " .. i.type .. " expects type of register, number, or label")
        end
    end


    while register['ip'] <= #tokens and not had_error do
        local i = advance()
        if i.type == instructions['set'] then
            local reg = advance()
            assertRegister(reg.lexeme)
            local val = advance()
            if val.type == 'NULL' then
                register[reg.lexeme] = Token('NULL')
            else
                register[reg.lexeme] = val.literal
            end
        elseif i.type == instructions['cpy'] then
            local reg_a = advance()
            local reg_b = advance()
            assertRegister(reg_a.lexeme, reg_b.lexeme)
            register[reg_b.lexeme] = register[reg_a.lexeme]
        elseif i.type == instructions['mov'] then
            local reg_a = advance()
            local reg_b = advance()
            assertRegister(reg_a.lexeme, reg_b.lexeme)
            register[reg_b.lexeme] = register[reg_a.lexeme]
            register[reg_a.lexeme] = Token('NULL')
        elseif i.type == instructions['psh'] then
            local val = advance()
            if isRegister(val.lexeme) then
                table.insert(stack, register[val.lexeme])
            elseif val.type == 'NUMBER' then
                table.insert(stack, val.literal)
            else
                report(i.line, "Instruction " .. i.type .. " expects type of register or number", 0)
            end
        elseif i.type == instructions['pop'] then
            table.remove(stack)
        elseif i.type == instructions['dup'] then
            table.insert(stack, stack[#stack])
        elseif i.type == instructions['swp'] then
            local tmp = stack[#stack]
            stack[#stack] = stack[#stack-1]
            stack[#stack-1] = tmp
        elseif i.type == instructions['str'] then
            local reg = advance()
            assertRegister(reg.lexeme)
            if type(register[reg.lexeme]) == 'table' then
                if register[reg.lexeme].type == 'NULL' then report(i.line,  "Cannont store type NULL") end
            end
            table.insert(stack, register[reg.lexeme])
            register[reg.lexeme] = Token('NULL')
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
        elseif i.type == instructions['pow'] then
            local b = table.remove(stack)
            local a = table.remove(stack)
            table.insert(stack, a ^ b)
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
                report(i.line, "Instruction " .. i.type .. " expects type of register or number")
            end
        elseif i.type == instructions['jmp'] then
            local val = advance()
            handle_jump(i, val)
        elseif i.type == instructions['jeq'] then
            local val = advance()
            local cond = table.remove(stack)
            if cond ~= 0 and cond ~= nil then
                handle_jump(i, val)
            end
        elseif i.type == instructions['jne'] then
            local val = advance()
            if table.remove(stack) == 0 then
                handle_jump(i, val)
            end
        elseif i.type == instructions['slp'] then
            local val = advance()
            if isRegister(val.lexeme) then
                sleep(register[val.lexeme])
            elseif val.type == 'NUMBER' then
                sleep(val.literal)
            else
                report(i.line, "Instruction " .. i.type .. " expects type of register or number")
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
                report(i.line, "Instruction " .. i.type .. " expects type of register or number")
            end
        elseif i.type == instructions['out'] then
            local val = advance()
            if isRegister(val.lexeme) then
                write(register[val.lexeme])
            elseif val.type == 'NUMBER' then
                write(val.literal)
            else
                report(i.line, "Instruction " .. i.type .. " expects type of register or number")
            end
        elseif i.type == instructions['dmp'] then
            printt( rev(stack) )
        elseif i.type == instructions['imp'] then
            local file = advance()
            if file.type ~= 'STRING' then report(i.line, "Instruction " .. i.type .. " expects type of string") end
            if fs.isDir(file.literal) or not fs.exists(file.literal) then report(i.line, "Could not import file " .. file.literal) end
            local h = fs.open(file.literal, 'r')
            local code = h.readAll()
            h.close()
            sub_parse(lex(code))
        elseif i.type == instructions['hlt'] then
            break
        elseif i.type == 'LABEL' then
        elseif i.type == 'START' then
            local name = advance()
            local argc = nil
            if peek().type == 'NUMBER' then
                argc = advance().literal
            else
                argc = 0
            end

            local m = {}
            m.body = {}
            m.count = argc
            local t = advance()
            while t.type ~= 'END' do
                table.insert(m.body, t)
                t = advance()
            end
            macros[name.lexeme] = m
        elseif i.type == 'MACRO' then
            if not macros[i.lexeme] then report(i.line, "Undefined macro " .. i.lexeme) end
            if macros[i.lexeme].count > 0 then
                local args = {}
                for _ = 1, macros[i.lexeme].count do
                    table.insert(args, advance())
                end

                for k = 1, macros[i.lexeme].count do
                    for j = 1, #macros[i.lexeme].body do
                        if macros[i.lexeme].body[j].lexeme == tostring(k) and macros[i.lexeme].body[j].type == 'MACRO' then
                            macros[i.lexeme].body[j].type = args[k].type
                            macros[i.lexeme].body[j].lexeme = args[k].lexeme
                            macros[i.lexeme].body[j].literal = args[k].literal
                        end
                    end
                end
            end

            sub_parse( macros[i.lexeme].body )
        else
            report(i.line, "Unexpected " .. i.type .. " " .. i.lexeme)
        end
    end
end

return parse