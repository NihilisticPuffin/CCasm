local instructions = {
    ['set'] = 'SET',
    ['mov'] = 'MOVE',
    ['psh'] = 'PUSH',
    ['pop'] = 'POP',
    ['ldr'] = 'LOAD',
    ['str'] = 'STORE',
    ['add'] = 'ADD',
    ['sub'] = 'SUBTRACT',
    ['mul'] = 'MULTIPLY',
    ['div'] = 'DIVIDE',
    ['mod'] = 'MODULO',
    ['cmp'] = 'COMPARE',
    ['jmp'] = 'JUMP',
    ['jne'] = 'JUMP_NOT_EQUAL',
    ['slp'] = 'SLEEP',
    ['utc'] = 'UTC',
    ['dmp'] = 'DUMP',
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