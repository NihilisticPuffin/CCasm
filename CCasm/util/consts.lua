--[[
    New Instructions:
        imp: Import another file to allow for creation of macro libraries
            Ex: imp "lib.asm" <-- Would aslo need to add support for strings in lexer
        dup: Duplicates top value of stack
        swp: Swaps top two values on stack
        jeq: Jump if top value of stack is not 0
             Same functionality jmp currently has
             jmp would be changed to always jump

    Planned Features:
        Change jump instructions to pop values off stack
        Change the str instruction to set a register to 0 after storing value to stack
        Add support for registers with psh instruction
            Would not set register to 0 meaning psh a and str a would behave differently
        Add support for hex numbers prefixed with dollar sign ($) -- Implemented Needs Testing
            Ex: set a $FA <-- set a to 250
        Add support for macro calls to take arguments
            Ex:
                %macro add 2 <-- Number of arguments macro takes
                    psh %1
                    psh %2
                    add
                %end

                %add 5 4
]]--

local instructions = {
    ['set'] = 'SET',
    ['mov'] = 'MOVE',
    ['psh'] = 'PUSH',
    ['pop'] = 'POP',
    --['dup'] = 'DUPLICATE',
    --['swp'] = 'SWAP',
    ['ldr'] = 'LOAD',
    ['str'] = 'STORE',
    ['add'] = 'ADD',
    ['sub'] = 'SUBTRACT',
    ['mul'] = 'MULTIPLY',
    ['div'] = 'DIVIDE',
    ['mod'] = 'MODULO',
    ['cmp'] = 'COMPARE',
    ['jmp'] = 'JUMP',
    --['jeq'] = 'JUMP_IF_EQUAL',
    ['jne'] = 'JUMP_NOT_EQUAL',
    ['slp'] = 'SLEEP',
    ['utc'] = 'UTC',
    ['dmp'] = 'DUMP',
    ['chr'] = 'CHARACTER',
    ['out'] = 'OUTPUT',
    --['imp'] = 'IMPORT',
    ['hlt'] = 'HALT',
}

local keywords = {
    ['macro'] = "START",
    ['end'] = "END"
}

return function()
    return instructions, keywords
end