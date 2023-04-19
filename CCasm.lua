local lex = require "CCasm.Lexer.lex"
local Token = require "CCasm.Lexer.Token"
local parse = require "CCasm.Parser.parse"
register = {
    ['a'] = Token('NULL'),
    ['b'] = Token('NULL'),
    ['c'] = Token('NULL'),
    ['d'] = Token('NULL'),
    ['e'] = Token('NULL'),
    ['ip'] = 1,
}
stack = {}
labels = {}
macros = {}

local args = {...}
if #args > 1 then
    error("Usage: CCasm [path]", 0)
end
local function report(line, where, message)
    io.stderr:write('[line ' .. line .. '] Error' .. where .. ': ' .. message .. '\n')
    had_error = true
end

local function general_error(line, message)
    report(line, '', message)
end

local function repl()
    while true do
        write(">: ")
        input = read()
        register['ip'] = 1
        parse( lex(input, general_error) )
    end
end

local function run_file()
    local asm = fs.open(args[1], 'r')
    local code = asm.readAll()
    asm.close()
    parse( lex(code, general_error) )
end

if #args == 0 then
    repl()
else
    run_file()
end