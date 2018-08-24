/* nmenumnt.p */
{prg_head.f}
define buffer b-nmenu for nmenu.
def buffer bnmdes for nmdes.
def var trofc as char format "x(27)".
define var v-father like nmenu.father initial "MENU".
define var v-fname  like nmenu.fname.
define var v-max    as   int.
define var v-proc   like nmenu.proc.
define var v-ln like nmenu.ln.
define var v-ans as log.
def var addmn as log.
def var ok1 as log.
def var i as int64.
repeat:
    repeat:
        addmn = no.
        v-max = 0.
        form nmenu.ln nmdes.des nmenu.fname nmenu.link nmenu.proc
        with centered row 4 no-box 13 down frame nmenu.
        clear frame nmenu all no-pause.
        for each nmenu where nmenu.father eq v-father:
            find nmdes where nmdes.lang eq g-lang
            and  nmdes.fname eq nmenu.fname no-error.
            disp nmenu.ln nmdes.des when available nmdes
            nmenu.fname nmenu.link nmenu.proc
            with frame nmenu.
            v-max = nmenu.ln.
            if v-max ge 13 then leave.
            down with frame nmenu.
        end.
        choose row nmenu.ln go-on("CTRL-D" "DEL-LINE") with frame nmenu.
        if keyfunction(lastkey) eq "DELETE-LINE" then do:
            find nmenu where nmenu.father eq v-father
            and  nmenu.ln eq int64(frame-value).
            {mesg.i 9860} update v-ans.
            if v-ans eq false then next.
            v-ln = nmenu.ln.
            for each nmdes where nmdes.fname eq nmenu.fname:
                delete nmdes.
            end.
            delete nmenu.
            for each b-nmenu where b-nmenu.father eq v-father
                and  b-nmenu.ln ge v-ln by b-nmenu.ln:
                b-nmenu.ln = b-nmenu.ln - 1.
            end.
            next.
        end.
        else if frame-value eq "" then do:
            create nmenu.
            nmenu.father = v-father.
            nmenu.ln = v-max + 1.
            display nmenu.ln nmenu.fname with frame nmenu.
            create nmdes.
            nmdes.lang = g-lang.
            addmn = yes.
        end.
        else do:
            find nmenu where nmenu.father eq v-father
            and  nmenu.ln eq int64(frame-value).
            find nmdes where nmdes.lang eq g-lang
            and  nmdes.fname eq nmenu.fname no-error.
            if not available nmdes then do:
                create nmdes.
                nmdes.lang = g-lang.
            end.
        end.
        display nmdes.des nmenu.fname nmenu.link nmenu.proc nmenu.ln
        with frame nmenu.
        nmenu.proc:width in frame nmenu = 8.
        nmenu.proc:format in frame nmenu = "x(200)".
        prompt-for nmdes.des nmenu.fname nmenu.link nmenu.proc nmenu.ln
        with frame nmenu.
        if nmenu.ln entered then do:
            if input nmenu.ln eq 0 then do:
                v-ln = nmenu.ln.
                for each nmdes where nmdes.fname eq nmenu.fname:
                    delete nmdes.
                end.
                delete nmenu.
                for each b-nmenu where b-nmenu.father eq v-father
                    and  b-nmenu.ln ge v-ln by b-nmenu.ln:
                    b-nmenu.ln = b-nmenu.ln - 1.
                end.
                next.
            end.
            else
            for each b-nmenu where b-nmenu.father eq v-father
                and  b-nmenu.ln ge input nmenu.ln
                by b-nmenu.ln descending:
                b-nmenu.ln = b-nmenu.ln + 1.
            end.
        end.
        if nmenu.fname entered then
            for each b-nmenu where b-nmenu.father eq nmenu.fname:
                b-nmenu.father = input nmenu.fname.
            end.
            assign nmdes.des nmenu.fname nmenu.link nmenu.proc nmenu.ln.
            nmdes.fname = nmenu.fname.
            if nmenu.link eq "" and nmenu.proc eq "" then do:
                v-father = nmenu.fname.
                next.
            end.
            if nmenu.proc ne "" then do:
                find bnmdes where bnmdes.fname eq nmenu.fname and 
                bnmdes.lang eq "WH" no-error.
                if not available bnmdes then do:
                    create bnmdes.
                    assign bnmdes.fname = nmenu.fname
                    bnmdes.lang = "WH".
                end.
                assign bnmdes.des = string(today,"99/99/9999") + " " +
                                    string(time,"hh:mm:ss") + " " +
                                    userid(ldbname(1)).
                
            end.
        end.
        if v-father ne "MENU" then do:
            find nmenu where nmenu.fname eq v-father.
            v-father = nmenu.father.
        end.
        else leave.
    end.
