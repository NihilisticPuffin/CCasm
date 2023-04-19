# CCasm
An interpreted assembly-like language for computercraft

## Instruction Set
|  Instruction | Use  |
| ------------ | ------------ |
| set [reg] [val] | Sets the value of a register |
| cpy [reg_a] [reg_b] | Copies the value of reg_a into reg_b |
| mov [reg_a] [reg_b] | Moves the value of reg_a into reg_b and sets reg_a to null |
| psh [reg:val] | Pushes a value onto the stack, does not set register to null after pushing |
| pop | Pops a value off the stack |
| str [reg] | Stores the value of a register onto the stack and sets register to null |
| ldr [reg] | Pops the top value off the stack and stores into register |
| add | Pops the top two values off the stack, adds them and pushes the result onto the stack |
| sub | Pops the top two values off the stack, subtracts them and pushes the result onto the stack |
| mul | Pops the top two values off the stack, multiplies them and pushes the result onto the stack |
| div | Pops the top two values off the stack, divides them and pushes the result onto the stack |
| mod | Pops the top two values off the stack, preforms a modulo operation and pushes the result onto the stack |
| cmp [reg] [reg:val] | Compares the value of a register with another register or value |
| jmp [reg:val:label] | Jumps to the line number of register or value or to a label |
| jeq [reg:val:label] | Jumps to the line number of register or value or to a label if top value of stack is not zero |
| jne [reg:val:label] | Jumps to the line number of register or value or to a label if top value of stack is zero |
| utc [reg] | Sets value of register to number of milliseconds since UNIX Epoch |
| slp [val] | Sleeps for given number of seconds |
| dmp | Dumps stack to console for debugging |
| chr [reg:val] | Outputs the value or register as ASCII character |
| out [reg:val] | Outputs the value or register |
| imp [string] | Loads file and runs it |
| hlt | Halts the program |

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

## Macros
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

Timer.asm
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

Fibonacci
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

FizzBuzz
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