# CCasm
An interpreted assembly-like language for computercraft

## Instruction Set
|  Instruction | Name | Use |
| ------------ | ------------ | ------------ |
| set [reg] [val] | Set | Sets the value of a register |
| cpy [reg_a] [reg_b] | Copy | Copies the value of reg_a into reg_b |
| mov [reg_a] [reg_b] | Move | Moves the value of reg_a into reg_b and sets reg_a to null |
| psh [reg:val] | Push | Pushes a value onto the stack, does not set register to null after pushing |
| pop | Pop | Pops a value off the stack |
| dup | Duplicate | Duplicates the top value on the stack |
| swp | Swap | Swaps the top two values on the stack |
| str [reg] | Store | Stores the value of a register onto the stack and sets register to null |
| ldr [reg] | Load | Pops the top value off the stack and stores into register |
| add | Add | Pops the top two values off the stack, adds them and pushes the result onto the stack |
| sub | Subtract | Pops the top two values off the stack, subtracts them and pushes the result onto the stack |
| mul | Multiply | Pops the top two values off the stack, multiplies them and pushes the result onto the stack |
| pow | Power | Pops the top two values off the stack, raised the second value to the power of the first and pushes the result onto the stack |
| div | Divide | Pops the top two values off the stack, divides them and pushes the result onto the stack |
| mod | Modulo | Pops the top two values off the stack, preforms a modulo operation and pushes the result onto the stack |
| cmp [reg] [reg:val] | Compare | Compares the value of a register with another register or value |
| jmp [reg:val:label] | Jump | Jumps to the line number of register or value or to a label |
| jeq [reg:val:label] | Jump If Equal | Jumps to the line number of register or value or to a label if top value of stack is not zero |
| jne [reg:val:label] | Jump Not Equal | Jumps to the line number of register or value or to a label if top value of stack is zero |
| utc [reg] | UTC | Sets value of register to number of milliseconds since UNIX Epoch |
| slp [val] | Sleep | Sleeps for given number of seconds |
| dmp | Dump | Dumps stack to console for debugging |
| chr [reg:val] | Character | Outputs the value or register as ASCII character |
| out [reg:val] | Output | Outputs the value or register |
| imp [string] | Import | Loads file and runs it |
| hlt | Halt | Halts the program |

## Registers
CCasm has 5 general purpose registers (a, b, c, d, e) and an instruction pointer register (ip)

The ip register is modified by jump instructions but can also be changed with the set instruction
```
; Outputs a in an infinite loop
set a 1
out a
set ip 4 ; Note: The value 4 is used here because the out instuction is the 4th token in the program
```

## Preprocessor
Preprocessor commands begin with the hash symbol (#)

There is currently only one preprocessor command

New registers can be dynamicaly created by programs using the `#reg` preprocessor command followed by the register name
```
#reg new_register
set new_register 5
out new_register ; Outputs 5
```

## Comments
Comments in CCasm can be started with a semicolon (;) and continue until the end of the line

## Labels
Labels are defined by any alphabetic character and underscores [a-zA-Z_] followed by a colon (:)

Labels can be jumped to using jump instructions
```
set a 1
cmp a 1
jeq skip
out a
skip:
```
The `out a` instruction will be skipped by the `jeq skip`

## Numbers
Numbers in CCasm can be represented as any real number (Ex: 5, 3.14, -15) or as a hexideciaml number using a dollar sign (Ex: $FA, $B08A)

## Strings
CCasm currently has partial support for strings using double quotes ("), however strings may not behave properly in certain situations as they are currently only intended to work with the import instruction

## Macros
Macros can be used as simple function calls or to create things such as for and while loops (See: [libs/loops.asm](https://github.com/NihilisticPuffin/CCasm/blob/main/libs/loops.asm))

Macros are defined using the `%macro` keyword followed by an identifier and closed with the `%end` keyword

Macros are called with a % followed by the identifier
```
%macro hello
    chr 72
    chr 101
    chr 108
    chr 108
    chr 111
    chr 44
    chr 32
    chr 87
    chr 111
    chr 114
    chr 108
    chr 100
    chr 33
    chr 10
%end

%hello ; Prints 'Hello, World!' followed by a newline
```

Macros also support arguments by following the macro identifier with the number of arguments the macro takes

Macro arguments can be accessed within a macro using a % followed by the argument number
```
%macro say
    out a
    chr 10
%end

%macro for 3
    for_loop:
        %3 ; %3 gets replaced with %say

        cmp %1 %2 ; %1 and %2 get replaced with a and 5 respectively
        jeq for_exit
        str %1
        psh 1
        add
        ldr %1
        jmp for_loop
        for_exit:
%end

set a 1
%for a 5 %say ; Loops from value of a to 5 and outputs a
```

# Examples

WARNING: CCasm is currently under-development, examples may be broken by future updates

## Timer.asm
```
utc d

%macro elapsed
    ; Calculate time elapsed in milliseconds
    utc e
    str e
    str d
    sub
    ldr e
    out e
    chr 109 ;m
    chr 115 ;s
    chr 10 ;\n
%end
```

## Fibonacci
```
imp "Timer.asm"
set a 90 ; Iterations
set b 0 ; Previous Number
set c 1 ; Current Number

fib:
    cmp a 1
    jeq _exit
    str a
    psh 1
    sub
    ldr a
    psh b
    psh c
    add
    mov c b
    ldr c
    jmp fib

_exit:
    out c ; Print output of Fibonacci
    chr 10 ; \n
    %elapsed
```
## Factorial
```
imp "Timer.asm"
set a 1
set b 5
set c 1

fac:
    psh a
    dup
    psh c
    mul
    ldr c
    cmp a b
    jeq _exit
    psh 1
    add
    ldr a
    jmp fac


_exit:
    out c
    chr 10
    %elapsed
```


## FizzBuzz
```
imp "Timer.asm"

set a 1
set c 17

%macro fizz
    chr 70
    chr 105
    chr 122
    chr 122
%end

%macro buzz
    chr 66
    chr 117
    chr 122
    chr 122
%end

loop:
    cpy a b
    str b
    dup
    dup

    psh 15
    mod
    ldr b
    cmp b 0
    jeq fizz_buzz

    psh 3
    mod
    ldr b
    cmp b 0
    jeq fizz

    psh 5
    mod
    ldr b
    cmp b 0
    jeq buzz

    out a
    chr 10

step:
    cmp a c
    jeq exit
    str a
    psh 1
    add
    ldr a
    jmp loop

fizz:
    %fizz
    chr 10
    jmp step

buzz:
    %buzz
    chr 10
    jmp step

fizz_buzz:
    %fizz
    %buzz
    chr 10
    jmp step

exit:
    %elapsed
```