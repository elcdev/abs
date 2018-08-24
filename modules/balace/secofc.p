/* secofc.p
*/
{prg_head.f} /* Security Maintenance by Officer */
define buffer b-nmenu for nmenu.
define var v-father like nmenu.father initial "MENU".
define var v-fname  like nmenu.fname.
define var v-max    as   int.
define var v-proc   like nmenu.proc.
define var v-ans as log.
define var v-stack as cha.
define var v-ln like nmenu.ln.
define var v-lnstack as cha.
define var v-deep as int64.
define var v-sts as cha format "x" label "S".
define var v-per as cha format "x" label "P".
define var trofc as char format "x(8)".
main: 
repeat:
    prompt-for sec.ofc
    with frame ofc side-label row 4 centered no-box.
    find ofc where ofc.ofc = input sec.ofc.
    display ofc.name with frame ofc.
    status default "Press GO to permit/prohibit to use...".
    repeat:
        repeat:
            v-max = 0.
            form nmenu.ln nmdes.des nmenu.fname nmenu.link v-sts v-per
            with centered row 5 no-box 13 down frame nmenu.
            clear frame nmenu all no-pause.
            for each nmenu where nmenu.father eq v-father:
                find nmdes where nmdes.lang eq g-lang
                and  nmdes.fname eq nmenu.fname no-error.
                if nmenu.proc eq "" and nmenu.link eq "" then
                v-sts = ">".
                else if nmenu.link ne "" then
                v-sts = "^".
                else
                v-sts = "".
                find sec where sec.ofc eq ofc.ofc and  sec.fname eq nmenu.fname no-error.
                if available sec then v-per = "*".
                else v-per = "".
                disp nmenu.ln
                nmdes.des when available nmdes
                nmenu.fname nmenu.link v-sts v-per
                with frame nmenu.
                v-max = nmenu.ln.
                if v-max ge 13 then leave.
                down with frame nmenu.
            end.
            choose row nmenu.ln with frame nmenu.
            if frame-value eq "" then do:
                bell.
                undo, retry.
            end.
            else do:
                find nmenu where nmenu.father eq v-father
                and  nmenu.ln eq int64(frame-value).
                find nmdes where nmdes.lang eq g-lang and  nmdes.fname eq nmenu.fname
                no-error.
            end.
            display nmdes.des when available nmdes
            nmenu.fname nmenu.link nmenu.ln
            with frame nmenu.
            if keyfunction(lastkey) eq "GO" then do:
                if nmenu.proc ne "" then do:
                    find sec where sec.ofc eq ofc.ofc and sec.fname eq nmenu.fname no-error.
                    if available sec then do:
                        delete sec.
                    end.
                    else do:
                        create sec.
                        assign sec.ofc = ofc.ofc
                               sec.proc  = trofc
                               sec.fname = nmenu.fname
                               sec.regdt = g-today
                               sec.whn   = today
                               sec.tim   = time
                               sec.who   = userid("bank").
                    end.
                end. /* Actual Program */
                else if nmenu.link ne "" then do:
                    bell.
                    {mesg.i 9862}.
                    next.
                end. /* Link */
            end. /* GO */
            if nmenu.link eq "" and nmenu.proc eq "" then
            v-father = nmenu.fname.
        end.
        if v-father ne "MENU" then do:
            find nmenu where nmenu.fname eq v-father.
            v-father = nmenu.father.
        end.
        else leave.
    end.
    status default.
end. /* main */
