# CCasm
An assembly language for computercraft

CCasm has 20 instructions
|  Instruction | Use  |
| ------------ | ------------ |
| set [reg] [val] | Sets the value of a register |
| mov [reg_a] [reg_b] | Copies the value of reg_a into reg_b |
| psh [val] | Pushes a value onto the stack |
| pop | Pops a value off the stack |
| str [reg] | Stores the value of a register onto the stack |
| ldr [reg] | Pops the top value off the stack and stores into register |
| add | Pops the top two values off the stack, adds them and pushes the result onto the stack |
| sub | Pops the top two values off the stack, subtracts them and pushes the result onto the stack |
| mul | Pops the top two values off the stack, multiplies them and pushes the result onto the stack |
| div | Pops the top two values off the stack, divides them and pushes the result onto the stack |
| mod | Pops the top two values off the stack, preforms a modulo operation and pushes the result onto the stack |
| cmp [reg] [reg:val] | Compares the value of a register with another register or value |
| jmp [reg:val:label] | Jumps to the line number of register or value or to a lable if top value of stack is not zero |
| jne [reg:val:label] | Jumps to the line number of register or value or to a lable if top value of stack is zero |
| utc [reg] | Sets value of register to number of milliseconds since UNIX Epoch |
| slp [val] | Sleeps for given number of seconds |
| dmp | Dumps stack to console for debugging |
| chr [reg:val] | Outputs the value or register as  |
| out [reg:val] | Outputs the value or register |
| hlt | Halts the program |

## Labels
Labels are defined by any alphabetic character and underscores [a-zA-Z_] followed by a colon (:)
Labels can be jumped to using jump instructions
```
set a 1
cmp a 1
jmp skip
out a
skip:
```
The `out a` instruction will be skipped by the `jmp skip`

## Macros
Macros are defined using the `%macro` keyword followed by and identifier and closed with the `%end` keyword
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

## Comments
Comments in CCasm can be started with a semicolon (;) and continue until the end of the line

# Examples

FizzBuzz
```
utc d

set a 1
set c 17

loop:
    mov a b
    str b
    psh 15
    mod
    ldr b
    cmp b 0
    jmp fizz_buzz

    mov a b
    str b
    psh 3
    mod
    ldr b
    cmp b 0
    jmp fizz

    mov a b
    str b
    psh 5
    mod
    ldr b
    cmp b 0
    jmp buzz

    out a
    chr 10

step:
    cmp a c
    jmp exit
    str a
    psh 1
    add
    ldr a
    jne loop

fizz:
    chr 70
    chr 105
    chr 122
    chr 122
    chr 10
    jmp step

buzz:
    chr 66
    chr 117
    chr 122
    chr 122
    chr 10
    jmp step

fizz_buzz:
    chr 70
    chr 105
    chr 122
    chr 122
    chr 66
    chr 117
    chr 122
    chr 122
    chr 10
    jmp step

exit:
; Calculate time in milliseconds to finish
    utc e
    str e
    str d
    sub
    ldr e
    out e
    chr 109 ;m
    chr 115 ;s
    chr 10 ;\n
```

Fibonacci
```
utc d
set a 90 ; Iterations
set b 0 ; Previous Number
set c 1 ; Current Number


fib:
cmp a 1
jmp _exit
str a
psh 1
sub
ldr a
str b
str c
add
mov c b
ldr c
jne fib

_exit:
out c ; Print output of Fibonacci
chr 10 ; \n
; Calculate time in milliseconds to finish
utc e
str e
str d
sub
ldr e
out e
chr 109 ;m
chr 115 ;s
chr 10 ;\n
```
