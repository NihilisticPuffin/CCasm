%macro PI
    psh 3.14159265358979323846
%end

%macro add 2 ; %1 + %2
    psh %1
    psh %2
    add
%end
%macro sub 2 ; %1 - %2
    psh %1
    psh %2
    sub
%end
%macro mul 2 ; %1 * %2
    psh %1
    psh %2
    mul
%end
%macro pow 2 ; %1 ^ %2
    psh %1
    psh %2
    pow
%end
%macro div 2 ; %1 / %2
    psh %1
    psh %2
    div
%end
%macro mod 2 ; %1 % %2
    psh %1
    psh %2
    mod
%end