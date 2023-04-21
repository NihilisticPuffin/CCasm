local lex = require "CCasm.Lexer.lex"
local Token = require "CCasm.Lexer.Token"
local parse = require "CCasm.Parser.parse"
register = {
    --[[ General Purpose Registers ]]--
    ['a'] = Token('NULL'),
    ['b'] = Token('NULL'),
    ['c'] = Token('NULL'),
    ['d'] = Token('NULL'),
    ['e'] = Token('NULL'),
    --[[ Instruction Pointer ]]--
    ['ip'] = 1,
}
stack = {}
labels = {}
macros = {}

local args = {...}
if #args > 1 then
    error("Usage: CCasm [path]", 0)
end
_G.report = function(line, message)
    io.stderr:write('[Line: ' .. line .. '] Error: ' .. message .. '\n')
    had_error = true
end

local function repl()
    while not had_error do
        write(">: ")
        local input = read()
        register['ip'] = 1
        parse( lex(input) )
    end
end

local function run_file()
    local asm = fs.open(args[1], 'r')
    local code = asm.readAll()
    asm.close()
    parse( lex(code) )
end

if #args == 0 then
    repl()
else
    run_file()
end