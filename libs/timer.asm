#register timer_start timer_end timer_elapsed

; Calculates time in milliseconds between %timer_start and %timer_end being called
; and stores the value in the timer_elapsed register

%macro timer_start
    utc timer_start
%end

%macro timer_end
    utc timer_end
    str timer_end
    str timer_start
    sub
    ldr timer_elapsed
%end