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

register = {
    ['a'] = 0,
    ['b'] = 0,
    ['c'] = 0,
    ['d'] = 0,
    ['e'] = 0,
    ['ip'] = 1,
}
stack = {}
labels = {}
macros = {}

parse( lex(code, general_error) )
