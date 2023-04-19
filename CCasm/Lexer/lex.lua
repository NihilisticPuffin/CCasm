local Token = require "CCasm.Lexer.Token"
local switch = require "CCasm.util.switch"
local instructions, keywords = require "CCasm.util.consts" ()

return function(source, error_reporter)
    local start = 1
    local current = 1
    local line = 1
    local tokens = {}

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
          ['$'] = hex_number,
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
              error_reporter(line, 'Unexpected character.')
            end
          end
        })
      end

      while not at_end() do
        start = current
        scan_token()
      end

      --add_token('EOF', nil, '')

      return tokens
end