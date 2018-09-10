def input parameter crc like crc.crc.
def input parameter dat  as date format "99/99/9999".
def input parameter dat1 as date format "99/99/9999".
def var ccrc as syscrc no-undo.
ccrc = new syscrc().
def var baseCrc as int64 no-undo.
def var n1 as int64 no-undo init 1.
def var n9 as int64 no-undo init 9.
def var crcEur as int64 no-undo.
crcEur = ccrc:crcEur.
def var oldrat as dec extent 9.
define variable i as int64 format ">9" initial 0.
def var fa as date.
def var aux-fa as date.
def var ok as log.
{global.i}.
find crc where crc.crc = crc no-lock no-error.
fa = dat.
output to din.txt.
EXPORT DELIMITER ";" g-comp + "  " + STRING(TODAY,"99.99.9999") + " " + STRING(TIME,"HH:MM:SS").
EXPORT DELIMITER ";"  "CURRENCY RATE REPORT". 
EXPORT DELIMITER ";" "PERIODS FROM: " + STRING(dat,"99.99.9999") + " TO " + STRING(dat1,"99.99.9999").
PUT SKIP(2).
EXPORT DELIMITER ";" "CURRENCY: " caps(crc.des) + " ( " + crc.code + " )".
PUT skip(1).
EXPORT DELIMITER ";" "DATE" "ECB RATE" "UNIT" "BUY RATE" "SELL RATE" .

cr :
repeat while fa le dat1 :
    find last crchis where crchis.crc = crc and crchis.rdt le fa no-lock 
    no-error.
    if available crchis then do :
        ok = no.
        do i = 1 to 9 :
            if crchis.rate[i] ne oldrat[i] then ok = yes.
        end.
        if ok = no then do :
            fa = fa + 1.
            next cr.
        end.    
        baseCrc = ccrc:baseCrc(crchis.rdt).
        if baseCrc = crcEur then do:
            n1 = 9.
            n9 = 1.
        end.
              
        EXPORT DELIMITER ";" STRING(fa,"99.99.9999")
        crchis.rate[n1] crchis.rate[n9] crchis.rate[2]   
        crchis.rate[3].
        do i = 1 to 9 :
            oldrat[i] = crchis.rate[i].
        end.    
        fa = fa + 1.
    end.
end.
output close.
hide message no-pause.
run prn_proc.r ("din.txt").
delete object ccrc no-error.
