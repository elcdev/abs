def var ccrc as syscrc no-undo.
ccrc = new syscrc().
def var baseCrc as int64 no-undo.
baseCrc = ccrc:BaseCrc().
def var n1 as int64 no-undo init 1.
def var n9 as int64 no-undo init 9.
def var crcEur as int64 no-undo.
crcEur = ccrc:crcEur.
if baseCrc = crcEur then do:
  n1 = 9.
  n9 = 1.
end.
def var tit as char format "x(60)".
define variable r as recid.
define variable s as char.
def var titx as char format "x(35)".
def var ok as log.
def temp-table wcrcbr
    field crc like crcbr.crc
    field des like crcbr.des
    field code like crcbr.code
    field rate1 as dec format ">9.9999999"
    field rate9 as dec
    field regdt like crcbr.regdt
    index crc is primary crc asc.
def var dat as date format "99/99/9999".
def var dat1 as date format "99/99/9999".
define query crcq for wcrcbr scrolling.
define browse crcb query crcq no-lock
    display
    wcrcbr.crc  label "Nr."
    wcrcbr.des  label "Description" format "x(27)"
    wcrcbr.code label "Code" format "x(3)"
    wcrcbr.rate9 label "Unit"  format ">,>>>,>>9"
    wcrcbr.rate1 label "ECB Rate"  format ">>>,>>9.9999999"
    wcrcbr.regdt label "Date" format "99/99/99"
    with 15 down scrollable 
    title tit.
for each crc no-lock :
    create wcrcbr.
    assign wcrcbr.crc   = crc.crc
           wcrcbr.des   = crc.des
           wcrcbr.code  = crc.code
           wcrcbr.regdt = crc.regdt
           wcrcbr.rate9 = crc.rate[n9].
           wcrcbr.rate1 = crc.rate[n1].
end.         
form 
    dat label "FROM DATE" dat1 label "TO DATE"
    with frame dd side-labels row 10 centered title
    " REPORT FOR PERIOD " overlay top-only color messages.
form crcb help "Enter-> History F1-> Report F4-> Quit"
 with frame crcf row 3 centered overlay no-box.
{global.i}.
on return of browse crcb do:
    r = recid(wcrcbr).
    find first wcrcbr where recid(wcrcbr) = r no-error.
    if available wcrcbr then do :
        run crc_h.p(wcrcbr.crc,wcrcbr.des + " ").
    end.    
end.
on go of browse crcb do:
    dat = g-today.
    dat1 = g-today.
    ok = no.
    cr:
    repeat while ok = no on endkey undo,leave :
        display dat dat1 with frame  dd.
        update dat dat1 with frame dd.
        if dat1 < dat then do :
            message "Incorrect period !".
            pause 3.
            hide message no-pause.
            next cr.
        end.
        ok = yes.
    end.
    hide frame dd no-pause.
    r = recid(wcrcbr).
    find first wcrcbr where recid(wcrcbr) = r no-error.
    if available wcrcbr then do :
        run rp_crc(wcrcbr.crc,dat,dat1).
    end.    
    hide frame dd no-pause.
    view frame crcf .
end.
on any-printable of browse crcb do:
  find first wcrcbr where string(wcrcbr.crc,"9")
   begins keylabel(lastkey) no-lock no-error.
  if available wcrcbr then do:
    r = recid(wcrcbr).
    reposition crcq to recid r.
  end.
end.
open query crcq for each wcrcbr.
enable crcb with frame crcf.
find first wcrcbr where string(wcrcbr.crc,"9") = frame-value no-lock no-error.
if available wcrcbr then do:
  r = recid(wcrcbr).
  reposition crcq to recid r.
end.
else do :
    find first wcrcbr no-lock no-error.
    if available wcrcbr then do :
        r = recid(wcrcbr).
        reposition crcq to recid r.
    end.
    else reposition crcq forward 1.
end.
wait-for end-error of crcb focus crcb.
delete object ccrc no-error.
