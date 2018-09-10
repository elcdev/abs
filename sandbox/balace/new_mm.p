/*
 MAIN MENU
*/
def variable nos as character extent 50 .
def variable numb as int64 extent 50.
def var i as int64.
def var k as int64.
def var t as int64.
def var txt as char.
def var tx2 as char.
def var kk as character.
def var kn as int64.
def var ky as int64 initial 0.
def var keyx as int64.
def var ms as character format "x(40)".
def var hdir as character.
def var ok as logical.
def var ms1 as character format "x(51)" no-undo
initial "Permission denied!".
form
    skip(1)
    ms no-label with frame ms centered row 10 attr-space color messages
    overlay title "ATTENTION".
form
    ms1 no-label with frame ms1 centered row 10 attr-space color messages
    overlay .
form
    txt
    label "CHOOSE MENU NUMBER OR TYPE FUNCTION'S NAME (For EXIT --> QUIT)"
    help ""
    with frame ccc side-labels
    attr-space row 21 column 4 no-box.
/* proverjajem, a jesli LDBNAME(1) u nas ne BANK, to vihodim iz programmi */ 
if LDBNAME(1) <> "BANK" then do:  
  message "Permission denied (First database is not [BANK])". pause 3 no-message.
  quit.
end.                                                                         
term = "xterm".
{global.i "new global"}.
{new_add.i}
on PF4 end-error.
SET_GLOBALS().
t = 0.
find ofc where ofc.ofc = ofcsec no-lock no-error.
if available ofc then do :
    if ofc.stn ne 9 then do :
        g-ofc = ofc.ofc.
        if ofc.father = "" then do :
            nos[1] = "MENU".
            numb[1] = 1.
            nos[2] = "MENU".
            numb[2] = 1.
        end.
        else do :
            nos[1] = ofc.father.
            numb[1] = 1.
            nos[2] = ofc.father.
            numb[2] = 1.
        end.
        i = 2.
    end.
    else do while t = 0 on endkey undo,next :
        message "This user is deactivated! Call to System Administrator !".
        pause 5 no-message.
        t = 1.
        quit.
    end.
    t = 0.
end.
else do while t = 0 on endkey undo,next :
    message "You aren't registred in System ! Please call to System Administrator !".
    pause 5 no-message.
    t = 1.
    quit. 
end.
t = 0.


if g-today < today  then do on endkey undo,next :
    ms = "System day " + string(g-today) + " is not closed !".
    display ms with frame ms.
    pause.
    hide frame ms no-pause.
end.
/* run new_mes.p. */
release ofc . 
repeat on endkey undo,next :
    repeat on endkey undo,leave :
        if not connected("bank") then 
         do:
            message "Please relogon to database [bank]...". 
            pause 3 no-message.
            return.
         end.
        hide all no-pause.
        term = "xterm".
        view frame ccc.
        status default.
        if k = 0 then do :
            run ww_mm.p(nos[i],numb[i],output ky).
        end.
        else run ww_mm.p(nos[i],1,output ky).
        if lastkey = -1 then do: /* disconnect bank .  */ 
            run f_ofcp.p ("", true).
            message "Permission denied". pause 3 no-message.
            return .
        end.  
        k = 0.
        if ky = 0 then do :
            apply lastkey.
            IF LASTKEY = keycode("RETURN") or
                lastkey = KEYCODE("CTRL-X") or
                lastkey = KEYCODE("F1") or
                lastkey = KEYCODE("PF1") then do :
                IF int64(FRAME-VALUE) = 0 then next.
                else do:
                    FIND nmenu WHERE nmenu.father = nos[i] and
                    nmenu.ln = int64(FRAME-VALUE) no-lock no-error.
                    find nmdes of nmenu where nmdes.lang = g-lang
                    no-lock no-error.
                    if available nmdes then g-mdes = nmdes.des.
                    else g-mdes = "".
                    g-fname = nmenu.fname.
                    if available nmenu then do :
                        if nmenu.proc <> "" then do :
                            run sec_run(ofcsec,nmenu.fname).
                            numb[i] = nmenu.ln.
                        end.
                        else do :
                            i = i + 1.
                            if nmenu.link <> "" then do :
                                kk = nmenu.link.
                                kn = nmenu.ln.
                                find nmenu where nmenu.fname = kk no-lock no-error.
                                if available nmenu then do :
                                    if nmenu.proc <> "" then do :
                                        run sec_run(ofcsec,nmenu.fname).
                                        numb[i] = nmenu.ln.
                                        leave.
                                    end.
                                    else do :
                                        nos[i] = nmenu.fname.
                                        numb[i - 1] = kn.
                                        numb[i] = 1.
                                        k = 1.
                                    end.
                                end.
                            end.
                            else do :
                                nos[i] = nmenu.fname.
                                numb[i - 1] = nmenu.ln.
                                numb[i] = 1.
                                k = 1.
                            end.
                        end.
                    end.
                end.
            end.
            if lastkey = keycode("F5")
                or lastkey = keycode("PF5") then do :
                if frame-value <> "" then do :
                    FIND nmenu WHERE nmenu.father = nos[i] and
                    nmenu.ln = int64(FRAME-VALUE) no-lock no-error.
                    find sysc where sysc.sysc = "FNHELP" no-lock no-error.
                    if available sysc then hdir = sysc.chval.
                    if search(hdir + nmenu.fname) <> ? then do :
                        hide all no-pause. 
                        unix pg
                        value(" -p \"   Press ENTER to continue...\" " +
                        hdir + nmenu.fname).
                    end.
                    else do :
                        message "There is no HELP for this MENU item !".
                        pause 3 no-message.
                        hide message no-pause.
                    end.
                end.
            end.
            if lastkey = keycode("cursor-left") or
               lastkey = keycode("cursor-right") then do :
                bell.
            end.
            if lastkey = keycode("cursor-up") and
            int64(frame-value) < 2 then do :
                bell.
            end.
            if lastkey = keycode("cursor-down") and
            (integer(frame-value) > 12  or int64(frame-value) < 1 ) then do :
                bell.
            end.
            if (lastkey > 64 and lastkey < 123) or lastkey = 14 then do :
                keyx = 0.
                if lastkey <> 14 then do:
                    txt = chr(lastkey).
                    update txt with frame ccc editing :
                        if keyx = 0 then do :
                            apply lastkey.
                        end.
                        keyx = 1.
                        readkey pause 60.
                        if lastkey = -1 then do:
                          apply 404.
                        end.
                        else do:
                          if lastkey = keycode("RETURN") then leave.
                          apply lastkey.
                        end.
                    end.
                end.
                else do:
                    if txt = "" then next.
                end.
                if txt = "QUIT" or txt = "quit" then do:
                    run password1.p.
                    quit.
                end.
                else do :
                    find nmenu where nmenu.fname = txt no-lock no-error.
                    if available nmenu then do :
                        find nmdes of nmenu where nmdes.lang = g-lang
                        no-lock no-error.
                        if available nmdes then g-mdes = nmdes.des.
                        else g-mdes = "".
                        g-fname = txt.
                        if nmenu.proc <> "" then do :
                            run sec_run(ofcsec,nmenu.fname).
                            numb[i] = nmenu.ln.
                        end.
                        else do :
                            i = i + 1.
                            if nmenu.link <> "" then do :
                                kk = nmenu.link.
                                kn = nmenu.ln.
                                find nmenu where
                                nmenu.fname = kk no-lock no-error.
                                if available nmenu then do :
                                    find nmdes of nmenu where nmdes.lang = g-lang
                                    no-lock no-error.
                                    if available nmdes then g-mdes = nmdes.des.
                                    else g-mdes = "".
                                    g-fname = txt.
                                    if nmenu.proc <> "" then do :
                                        run sec_run(ofcsec,nmenu.fname).
                                        numb[i] = kn.
                                        nos[i] = nmenu.fname.
                                        leave.
                                    end.
                                    else do :
                                        nos[i] = nmenu.fname.
                                        numb[i - 1] = kn.
                                        numb[i] = 1.
                                        k = 1.
                                    end.
                                end.
                            end.
                            else do :
                                nos[i] = nmenu.fname.
                                numb[i - 1] = nmenu.ln.
                                numb[i] = 1.
                                k = 1.
                            end.
                        end.
                    end.
                    else do :
                        message "Incorrect FUNCTION NAME !".
                        pause 3 no-message.
                        hide message no-pause.
                        next.
                    end.
                end.
            end.
        end.
        else do :
            message "This MENU item is not available !".
            pause 3 no-message.
            hide message no-pause.
            leave.
        end.
    end.
    if i > 1 then do :
        nos[i] = "".
        numb[i] = 0.
        i = i - 1.
        k = 0.
    end.
    else do :
        bell.
        k = 1.
    end.
end.
status default.
procedure sec_run:
    def buffer bnmenu for nmenu.
    def input param ofc1 as char.
    def input param fname as char.
    def var stdr_run as char.
    def var ostype as char no-undo.
    input through uname.
    import unformatted ostype.
    input close.
    if trim(ostype) = "Linux" then do:
        stdr_run = "/bank1/linux/bin/stdr_menu".
    end.
    else do:
        if os-getenv("SYS_TYPE")="TEST" then
        stdr_run = "/tplaton/programs/bin/stdr_menu".
        else
        stdr_run = "/bank/platon/bin/stdr_menu".  
    end.
    find bnmenu where bnmenu.fname eq fname no-lock no-error.
    if not available bnmenu then do:
        message "This program is not available !" fname.
        return.
    end.
    assign g-proc  = bnmenu.proc
           g-fname = bnmenu.fname.
 

    if can-find(sec where sec.ofc eq ofc1 and
        sec.fname eq bnmenu.fname and
        sec.sts ne 9)  then do:
        /* run set_title.p (bnmenu.fname,"",g-mdes). */
        if search(bnmenu.proc + ".p") ne ? then do:
            hide all no-pause.
            IF MENU_CONNECT_DBLIST(bnmenu.fname, 1) = 0 THEN  do:
                run value(bnmenu.proc + ".p").
                if g-ofc = "adm" then do:
                    run resize_screen.p (25,80, output ok).
                end.
            end.
            delete_objects(). /* Chistka objectov i lishnih podkljuchenij */
      
            on PF4 end-error.
            pause before-hide.
        end.
        else do:
            message "This program is not available !".
            pause 3 no-message.
            hide message no-pause.
        end.
    end.
    else do:
        display ms1 with frame ms1.
        run unaut_log(bnmenu.fname).
        pause 4 no-message.
        hide frame ms no-pause.
    end.
end procedure.
