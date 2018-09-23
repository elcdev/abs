
define variable deb  AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define variable kre  AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define variable atl  AS DECIMAL FORMAT "z,zzz,zzz,zzz,zz9.99-".
define variable details as character format "x(65)".
define variable line as int64 format "9999".
define variable glkon like transaction_line.gl.
define variable account as character format "x(12)" /*case-sensitive*/ .
define variable transaction_header as int64 format ">>>>>>>>>9".
define variable currency AS CHARACTER FORMAT "x(3)".
define variable account_name as character.
define variable debet AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define variable credit AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
/*
define variable atl  like account_balance.balance.
*/
define variable i as int64 format "9" initial 0.
define variable j as int64 format "9" initial 0.
define variable jh as int64 format ">>>>>>>9".
def var cndes as char format "x(25)".
define variable ques as logical format "Yes/No" initial yes.
/*
{global.i}.
*/
form transaction_header FORMAT ">>>>>>>>>9" no-label at 2 transaction_header.balance_date no-label at 13
    transaction_header.create_user no-label at 24 transaction_header.deal_number NO-LABEL AT 35
    with frame ccc row 2 overlay title 
    "Transaction Date       Create     Deal Reference                              ".
    
form atl label "BAL" to 27 deb label "TOTAL DR" to 54 kre label "TOTAL CR" to 79
    with frame cc1 row 5 side-labels overlay no-box.
form line no-label glkon no-label gl.short_name  FORMAT "x(20)" no-label 
    currency no-label account no-label SKIP
    account_name no-label format "x(33)"
    debet no-label to 59 credit no-label to 78 skip
    with frame cc3 ROW 6 scroll 4 4 down  overlay title
    "Line G/L account                   CRC SubAccount    Debet             Credit".
form
    details label "Details" at 2 skip
    with frame cc4 row 16 side-labels no-box overlay.


repeat while i = 0 on endkey undo,return :
    i = 0.
    hide all no-pause.
    clear frame ccc.
    clear frame cc1.
    
    clear frame cc3.
    clear frame cc4.
    view  frame ccc.
    view  frame cc1.
    
    view  frame cc3.
    view  frame cc4.
    
    MESSAGE "New(1) OLD(2)" update i .
    if i = 2 then do :
    clear frame ccc.
    clear frame cc1.
    clear frame cc3.
    clear frame cc4.
        run trx_entry.r(i).
        i = 0.
    end.
    if i = 1 then do :
        message "Вы уверены ?" update ques.
        if ques then do :
            hide message no-pause.
            message "Создается новая транзакция ...".
            run gl_led2n.r(i).
            i = 0.
        end.
        else i = 0.
    end.
end.
