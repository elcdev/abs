{euro_ready.i} /* by risger */
def var ccrc as syscrc no-undo.
ccrc = new syscrc().
def var baseCrc as int64 no-undo.
baseCrc = ccrc:BaseCrc().
def var n1 as int64 no-undo init 1.
def var n9 as int64 no-undo init 9.
def var crcEur as int64 no-undo.
crcEur = ccrc:crcEur.
def var codEur as cha no-undo.
codEur = ccrc:codEur.
IF baseCrc = crcEur THEN DO:
    n1 = 9.
    n9 = 1.
END. 
delete object ccrc no-error.
def var xauWarn as cha no-undo format "x(14)".
def var ti like crc.code.
define variable counter as int64 no-undo.
define variable recfound as logical no-undo.
define variable numdown as int64 init 15 no-undo.
define variable maxdown as int64 init 15 no-undo.
define variable oldchoice as character no-undo.
define variable choice as character.
define variable numrecsfound as int64 no-undo.
define variable scrrecid as recid extent 15.
define variable fa as date.
define variable key as int64 initial 0.
define variable tit as character.
{prg_head.f}.
tit = " Currency rates ".
for each company where company.sts ne 9 and 
    company.stc = "1" no-lock:
    tit = tit +  company.logo + ",".
end.
tit = substr(tit,1,length(tit) - 1) + " ".
fa = g-today.
outer: repeat for crc on endkey undo outer ,leave outer :
  inner: repeat on endkey undo inner,leave inner with frame scroll-frame  :
  form
    crc.crc  label "Nr."
    crc.des  label "Description" format "x(31)"
    crc.code label "Code" format "x(3)"
    crc.rate[n9] label "Unit"  format ">,>>>,>>9" 
    crc.rate[n1] label "ECB rate" format ">>>,>>9.9999"
    crc.regdt label "Date" format "99/99/99"
    with frame scroll-frame scroll 1 15 down attr-space CENTERED row 3 column 1
    overlay title tit.
    find next crc no-error.
    if available crc then do:
        recfound = yes.
        numrecsfound = 1.
        do counter = 1 to maxdown  :
            if available crc then do:
                display crc.crc crc.des crc.code crc.rate[n1] crc.rate[n9]
                crc.regdt.
                scrrecid[counter] = recid(crc).
            end.
            if frame-line = frame-down then leave.
            down.
            find next crc no-error.
            if available crc then numrecsfound = numrecsfound + 1.
            else do:
                clear no-pause.
            end.
        end.
        if frame-line gt 1 then
            up (frame-line - 1).
        if numrecsfound lt maxdown then do:
            numdown = numrecsfound.
        end.
    end.
    else do :
        find first crc no-error.
        if not available crc then do:
            recfound = no.
            numdown = 1.
            hide no-pause.
            return.
        end.
        else recfound = yes.
    end.
    oldchoice = "".
    choiceblk: repeat on endkey undo outer,leave outer with frame scroll-frame:
      status default.
        if recfound = yes then do:
            put cursor row frame-row(scroll-frame) column 3.
            choose row crc.crc help " "  no-error.
            color
            display normal crc.crc crc.des crc.code crc.rate[n1] crc.rate[n9]
            crc.regdt.
            pause 0.
            choice = keyfunction(lastkey).
            if lookup(choice,
            " ,page-up,page-down,cursor-up,cursor-down,return,go,end-error") = 0
            then do:
                message " Use correct keys(->,<-,Page-Up,Page-Down,Enter) !!! ".
                pause 2.
                hide message no-pause.
                undo,retry.
            end.
            if frame-value = ""
            then next.
            if frame-value <> oldchoice then do :
                oldchoice = frame-value.
                find crc no-lock
               where recid(crc) = scrrecid[frame-line] no-error.
            end.
            if choice = " " then do:
                oldchoice = "".
                next choiceblk.
            end.
        end.
        if choice = "page-down" then do:
            oldchoice = "".
            if frame-down ne frame-line then
            do counter = 1 to (maxdown - frame-line):
                find next crc no-error.
                if not available crc then
                next choiceblk.
            end.
            find next crc no-error.
            if available crc then do:
                find prev crc no-error.
                next outer.
            end.
            else next choiceblk.
        end.
        if choice = "page-up" then do:
            do counter = 1 to (maxdown + frame-line) on endkey undo,leave:
                find prev crc no-error.
            end.
            numdown = maxdown.
            hide.
            next outer.
        end.
        if choice = "cursor-down" then do :
            find next crc no-error.
            if not available crc then do :
                find last crc no-error.
                next.
            end.
            down.
            display crc.crc crc.des crc.code crc.rate[n1] crc.rate[n9]
            crc.regdt.
            do counter = 2 to maxdown:
                scrrecid[counter - 1] = scrrecid[counter].
            end.
            scrrecid[maxdown] = recid(crc).
        end.
        else if choice = "return" or choice = "go" then do :
            find crc where recid(crc) = scrrecid[integer(frame-line)] no-wait.
            cr:
            do while key = 0 on endkey UNDO cr, LEAVE cr :
                ti = crc.code.
                /**/
                color display messages crc.crc. 
                color display normal crc.des crc.code crc.rate[n9].
                /**/
                /*update crc.rate[1].*/
                PAUSE 0 before-hide.
                display ti label         "  CURRENCY" 
                with frame ss side-labels overlay CENTERED row 6 column 40.
                
                xauWarn = ''.
                if baseCrc = crcEur then do:
                  xauWarn = '(FOR ' + 
                  string(crc .rate[1]) + ' ' + codEur + ')'.
                  display xauWarn no-label 
                  with frame ss side-labels overlay row 6 column 54.
                end.
                do on endkey UNDO cr,leave cr:
                    PAUSE BEFORE-HIDE.
                    update SKIP
                       crc.rate[n1] LABEL "  ECB RATE" SKIP
                       crc.rate[2] label  "  BUY RATE" skip
                       crc.rate[3] label  " SELL RATE" skip
                       with frame ss side-labels overlay row 6 column 40.
                    key = 1.
                    crc.regdt = g-today.
                    find last crchis where crchis.crc = crc.crc and
                    crchis.rdt = g-today no-error.
                    if available crchis then do :
                        crchis.rate[1] = crc.rate[1].
                        crchis.rate[2] = crc.rate[2].
                        crchis.rate[3] = crc.rate[3].
                        crchis.rate[9] = crc.rate[9].
                        crchis.tim = time.
                        crchis.who = g-ofc.
                        crchis.whn = g-today.
                    end.
                    else do :
                        find last crchis where crchis.crc eq crc.crc and
                          crchis.rdt le g-today no-lock no-error.
                        if not available crchis or
                          crchis.rate[1] ne crc.rate[1] or
                          crchis.rate[2] ne crc.rate[2] or
                          crchis.rate[3] ne crc.rate[3] or
                          crchis.rate[9] ne crc.rate[9] then do:
                            create crchis.
                            crchis.crc = crc.crc.
                            crchis.des = crc.des.
                            crchis.decpnt = crc.decpnt.
                            crchis.code = crc.code.
                            crchis.rate[1] = crc.rate[1].
                            crchis.rate[2] = crc.rate[2].
                            crchis.rate[3] = crc.rate[3].
                            crchis.rate[9] = crc.rate[9].
                            crchis.sts = crc.sts.
                            crchis.tim = time.
                            crchis.who = g-ofc.
                            crchis.rdt = g-today.
                            crchis.whn = g-today.
                            crchis.regdt = today.
                        end.
                    end.
                end.
            end.
            HIDE FRAME SS NO-PAUSE.
            display crc.code crc.rate[n9] crc.rate[n1] crc.regdt.
            ti = "".
            key = 0.
            color display normal crc.crc.
        end.
        else if choice = "cursor-up" then do :
            find prev crc no-error.
            if not available crc then do :
                find first crc no-error.
                next.
            end.
            if numdown lt maxdown then do:
                numdown = numdown + 1.
                hide.
                view.
                pause 0.
            end.
            scroll down.
            display crc.crc crc.des crc.code crc.rate[n1] crc.rate[n9]
            crc.regdt.
            do counter = maxdown to 2 by -1:
                scrrecid[counter] = scrrecid[counter - 1].
            end.
            scrrecid[1] = recid(crc).
        end.
    end. /* choiceblk */
   end. /* inner */
end. /* outer */
status default.
