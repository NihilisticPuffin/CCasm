; args: [register] [value] [inc] [macro]
; Loops until register equals value, adds [inc] to register each loop
%macro for 4
    for_loop:
        %4 ; Macro to run each loop

        cmp %1 %2
        jeq for_exit
        str %1
        psh %3
        add
        ldr %1
        jmp for_loop
        for_exit:
%end

; args: [register] [value] [macro]
; Loops while register is equal to value
%macro while 3
    while_loop:
        %3

        cmp %1 %2
        jne while_exit
        jmp while_loop
        while_exit:
%end
