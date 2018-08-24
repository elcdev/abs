def input parameter crcx like crc.crc.
def input parameter titx as char format "x(20)".
def var ccrc as syscrc no-undo.
ccrc = new syscrc().
def var baseCrc as int64 no-undo.
baseCrc = ccrc:BaseCrc().
def var crcEur as int64 no-undo.
crcEur = ccrc:crcEur.
def var codEur as cha no-undo.
codEur = ccrc:codEur.
def var n1 as int64 no-undo init 1.
def var n9 as int64 no-undo init 9.
def var xauWarn as cha no-undo format "x(20)".
define variable r as recid.
define variable s as char.
def temp-table wcbr
    field dat as date format "99/99/9999"
    field rate1 as dec format "zzz,zz9.9999999" 
    field rate2 as dec format "zzz,zz9.9999999" 
    field rate3 as dec format "zzz,zz9.9999999" 
    field rate9 as dec format "zzz,zzz,zz9.99" 
    index dat is primary dat asc.
define query crcq for wcbr scrolling.
define browse crcb query crcq no-lock
    display
    wcbr.dat  label   "Date  "
    wcbr.rate1 label  "    ECB Rate" 
    wcbr.rate9 label  "     Unit" format ">,>>>,>>9" 
    with 12 down scrollable top-only title titx.
    
form     
        titx label        "  Currency" skip
        xauWarn LABEL     "      Unit" skip
        wcbr.dat   label  "      Date" skip
        wcbr.rate2 label  "  Buy Rate" skip
        wcbr.rate3 label  " Sell Rate" skip
        
        with frame ss1 side-labels overlay row 8 centered 
        color messages width 35.
    
form crcb 
help "ENTER-Details F4-Quit"
  with frame crcf row 5 column 22 centered overlay NO-BOX.
for each crchis where crchis.crc = crcx use-index crcrdt no-lock :
    create wcbr.
    assign wcbr.dat = crchis.rdt.
    n1 = 9.
    n9 = 1.
    wcbr.rate1 = crchis.rate[n1].
    wcbr.rate2 = crchis.rate[2].
    wcbr.rate3 = crchis.rate[3].
    wcbr.rate9 = crchis.rate[n9].
end.
titx = TRIM(titx).
on return of browse crcb do :
    r = recid(wcbr).
    find wcbr where recid(wcbr) = r no-lock no-error.
    if available wcbr then do :
        xauWarn = ''.
        if ccrc:baseCrc(wcbr.dat) = crcEur then do:
          xauWarn = '(FOR ' +
          string(wcbr.rate9) + ' ' + codEur + ')'.
        end.
        cr:
        DO ON ENDKEY UNDO, LEAVE cr:
            display titx wcbr.dat xauWarn wcbr.rate2 wcbr.rate3 
            HELP "F4-Quit" with frame ss1.
            pause.
        END.    
        hide frame ss1 no-pause.
    end.
end.        
on any-printable of browse crcb do:
  find first wcbr where string(wcbr.dat)
   begins keylabel(lastkey) no-error.
  if available wcbr then do:
    r = recid(wcbr).
    reposition crcq to recid r.
  end.
end.
open query crcq for each wcbr.
enable crcb with frame crcf.
HIDE FRAME ss1 no-pause.
find first wcbr where string(wcbr.dat) = frame-value no-error. 
if available wcbr then do:
  r = recid(wcbr).
  reposition crcq to recid r.
end.
else do :
    find last wcbr no-error.
    if available wcbr then do :
        r = recid(wcbr).
        reposition crcq to recid r.
    end.
    else reposition crcq forward 1.
end.
wait-for end-error of crcb focus crcb.
delete object ccrc no-error.
