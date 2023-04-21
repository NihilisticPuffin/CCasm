local instructions = {
    ['set'] = 'SET',
    ['cpy'] = 'COPY',
    ['mov'] = 'MOVE',
    ['psh'] = 'PUSH',
    ['pop'] = 'POP',
    ['dup'] = 'DUPLICATE',
    ['swp'] = 'SWAP',
    ['ldr'] = 'LOAD',
    ['str'] = 'STORE',
    ['add'] = 'ADD',
    ['sub'] = 'SUBTRACT',
    ['mul'] = 'MULTIPLY',
    ['pow'] = 'POWER',
    ['div'] = 'DIVIDE',
    ['mod'] = 'MODULO',
    ['cmp'] = 'COMPARE',
    ['jmp'] = 'JUMP',
    ['jeq'] = 'JUMP_IF_EQUAL',
    ['jne'] = 'JUMP_NOT_EQUAL',
    ['slp'] = 'SLEEP',
    ['utc'] = 'UTC',
    ['dmp'] = 'DUMP',
    ['key'] = 'KEY',
    ['chr'] = 'CHARACTER',
    ['out'] = 'OUTPUT',
    ['hlt'] = 'HALT',
}

local keywords = {
    ['macro'] = "START",
    ['end'] = "END"
}

return function()
    return instructions, keywords
end