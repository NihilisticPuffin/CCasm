local Token = require "CCasm.Lexer.Token"
local switch = require "CCasm.util.switch"
local instructions, keywords = require "CCasm.util.consts" ()

local start = 1
local current = 1
local line = 1
local tokens = {}

local nest = {}

local function lex(source)
    local function sub_lex(source)
        local tmp = {start = start, current = current, line = line}
        table.insert(nest, tmp)
        start, current, line = 1, 1, 1
        lex(source)
        tmp = table.remove(nest)
        start, current, line = tmp.start, tmp.current, tmp.line
    end

    local function at_end()
        return current > #source
    end

    local function advance()
        current = current + 1
        return source:sub(current - 1, current - 1)
    end

    local function add_token(type, literal, text)
        text = text or source:sub(start, current - 1)
        table.insert(tokens, Token(type, text, literal, line))
    end

    local function TokenAdder(type, literal)
        return function() add_token(type, literal) end
    end

    local function peek()
        return source:sub(current, current) or '\0'
    end

    local function peek_next()
        return source:sub(current + 1, current + 1) or '\0'
    end

    local function consume_comment()
        while peek() ~= '\n' and not at_end() do
            advance()
        end
    end

    local function is_digit(c)
        return c:match('%d')
    end

    local function add_number()
        while is_digit(peek()) do advance() end

        if peek() == '.' and is_digit(peek_next()) then
            advance()
            while is_digit(peek()) do advance() end
        end

        add_token('NUMBER', tonumber(source:sub(start, current - 1)))
    end

    local function add_string()
        start = current
        while peek() ~= '"' and not at_end() do advance() end
        add_token('STRING', source:sub(start, current - 1))
        advance()
    end

    local function is_alpha(c)
        return c:match('[%a_]')
    end

    local function is_hex(c)
        return c:match('[%x]')
    end

    local function is_alphanumeric(c)
        return is_digit(c) or is_alpha(c)
    end

    local function add_identifier()
        while is_alpha(peek()) do advance() end

        local text = source:sub(start, current - 1)
        if peek() == ':' then
            add_token('LABEL')
            advance()
        elseif text == 'null' then
            add_token('NULL')
        else
            add_token(instructions[text] or 'IDENTIFIER')
        end
    end

    local function add_macro()
        start = current
        while is_alphanumeric(peek()) do advance() end

        local text = source:sub(start, current - 1)
        add_token(keywords[text] or 'MACRO')
    end

    local function pre_proc()
        local args = {}
        start = current
        while is_alphanumeric(peek()) do advance() end
        local keyword = source:sub(start, current - 1)

        while peek() ~= '\n' and not at_end() do
            advance() --Consume Space
            start = current
            if peek() == '\"' then
                advance()
                start = current
                while peek() ~= '\"' do if peek() == '\n' or at_end() then report(line, "Unterminated string") end advance() end
                table.insert(args, source:sub(start, current - 1))
                advance()
            else
                while is_alphanumeric(peek()) do advance() end
                table.insert(args, source:sub(start, current - 1))
            end
        end
        if keyword == 'register' then
            for _, value in ipairs(args) do
                register[value] = Token('NULL')
            end
        elseif keyword == 'import' then
            if not fs.exists(args[1]) then report(line, "Could not include " .. args[1]) end
            local h = fs.open(args[1], 'r')
            local code = h.readAll()
            h.close()

            sub_lex(code)
        end
    end

    local function hex_number()
        start = current
        while is_hex(peek()) do advance() end

        add_token('NUMBER', tonumber(source:sub(start, current - 1), 16))
    end

    local function scan_token()
        switch(advance(), {
            [';'] = consume_comment,
            ['"'] = add_string,
            ['%'] = add_macro,
            ['#'] = pre_proc,
            ['$'] = hex_number,
            ['-'] = add_number,
            [' '] = load'',
            ['\r'] = load'',
            ['\t'] = load'',
            ['\n'] = function() line = line + 1 end,
            [switch.default] = function(c)
                if is_digit(c) then
                    add_number()
                elseif is_alpha(c) or c == '_' then
                    add_identifier()
                else
                    report(line, 'Unexpected character.')
                end
            end
        })
    end

    while not at_end() do
        start = current
        scan_token()
    end

    return tokens
end

return lex