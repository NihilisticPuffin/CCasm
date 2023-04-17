local lex = require "CCasm.Lexer.lex"
local parse = require "CCasm.Parser.parse"

local args = {...}
if #args < 1 then
    error("Usage: CCasm <file>", 0)
end
local function report(line, where, message)
    io.stderr:write('[line ' .. line .. '] Error' .. where .. ': ' .. message .. '\n')
    had_error = true
end

local function general_error(line, message)
    report(line, '', message)
end

local asm = fs.open(args[1], 'r')
local code = asm.readAll()
asm.close()

h = fs.open("tokens.asm.out", 'w')
h.write(textutils.serialize(lex(code, general_error)))
h.close()

parse( lex(code, general_error) )