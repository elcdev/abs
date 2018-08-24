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
initial "Atvainojiet ! J╜ms nav at╣auts veikt ╫o proced╜ru !".
form
    skip(1)
    ms no-label with frame ms centered row 10 attr-space color messages
    overlay title "BR╖DIN┘JUMS".
form
    ms1 no-label with frame ms1 centered row 10 attr-space color messages
    overlay .
form
    txt
    label "IZVЁLЁTIES MENU NUMURU VAI FUNKCIJAS NOSAUKUMU  (IZEJA --> QUIT)"
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
def var conncnt as int64 init 0 no-undo.  
def var maxses as int64 init 3 no-undo.
find first unicat where unicat.catid eq "SESSION MAX NUM" and
unicat.field1 eq g-ofc no-lock no-error.
if not avail unicat then 
    find first unicat where unicat.catid eq "SESSION MAX NUM" and
    unicat.field1 eq "" no-lock no-error.
    
if avail unicat then maxses = int64(unicat.field2) no-error.
for each bank._Connect NO-LOCK WHERE bank._Connect._Connect-Name eq g-ofc: 
  if lookup(bank._Connect._Connect-Type,"SELF,REMC",",") = 0 then next.
  conncnt = conncnt + 1.
end.
if conncnt gt maxses and g-ofc ne "DWHBASE" then do:
    message "VAIR┘K NEK┘ " + string(maxses) + 
    " SESSIJAS ATVЁRTAS AR LIETOT┘JU " + g-ofc + " !" 
    view-as alert-box.
    return.
end.
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
        message
 "Данный пользователь деактивирован ! Обратитесь к Системному Администратору !".
        pause 5 no-message.
        t = 1.
        quit.
    end.
    t = 0.
end.
else do while t = 0 on endkey undo,next :
    message
 "Вы не зарегистрированы в системе ! Обратитесь к Системному Администратору !".
    pause 5 no-message.
    t = 1.
    quit.
end.
t = 0.
{new_mm_ip_check.i}
if today eq 12/31/2005 or today eq 01/01/2006 then do:
  if not "alechi;adm;edgarp;vadvas;dmikai" matches "*" + ofc.ofc + "*" then do:
    message "Happy New Year!".
    pause 2 no-message.
    quit.
  end.
end.
if g-today < today  then do on endkey undo,next :
    ms = "Bankas diena " + string(g-today) + " vёl nav slёgta !".
    display ms with frame ms.
    pause.
    hide frame ms no-pause.
end.
run password.
run new_mes.r.
run f_ofcp.r ("", false).
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
        if g-ofc eq "alechi" then disp txt with frame ccc.
        status default.
        if k = 0 then do :
            run ww_mm.p(nos[i],numb[i],output ky).
        end.
        else run ww_mm.p(nos[i],1,output ky).
        if lastkey = -1 then 
         do: /* disconnect bank .  */ 
          run f_ofcp.r ("", true).
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
            if lastkey eq keycode("F7") or
               lastkey eq keycode("PF7") then do :
              if frame-value ne "" then do :
                find nmenu where nmenu.father eq nos[i] and
                                 nmenu.ln eq int64(frame-value)
                                   no-lock no-error.
                if available nmenu and nmenu.proc ne "" then do:
                  run trofc_vw.r(nmenu.fname).
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
                    value(" -p \"   Нажмите ENTER для продолжения...\" " +
                    hdir + nmenu.fname).
                    end.
                    else do :
                        message "Помощь по данному пункту меню отсутствует !".
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
                  run f_ofcp.r ("", true).
                  run password1.
                  quit.
                end.
                else if txt eq "STOP" then run delprc.r.
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
                        if g-ofc eq "alechi" then do:
                          find nmenu where nmenu.proc eq txt no-lock no-error.
                          if available nmenu then do:
                            txt = nmenu.fname.
                          end.
                        end.
                        message "Не верно указано название функции !".
                        pause 3 no-message.
                        hide message no-pause.
                        next.
                    end.
                end.
            end.
            if keyfunction(lastkey) = "%" and
              ( can-find( first sec where sec.ofc = ofcsec and
  ( sec.fname = "CFENT0" or sec.fname = "CFENTE" or sec.fname = "CEQCS8" )
                                 and sec.sts ne 9) /*or
                ofcsec = "root"*/ ) then do :
              run i_card.r.
            end.
        end.
        else do :
            message "Данное меню недоступно !".
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
  message "Данная программа не доступна ! " fname.
  return.
end.
assign g-proc  = bnmenu.proc
       g-fname = bnmenu.fname.
 
/* Программа 6-10-4: "ANKETA" может оставлять соединение на eBank */
if bnmenu.fname ne "ANKETA" then do:
  if connected("ebank") then disconnect ebank.
end.
if can-find(sec where sec.ofc eq ofc1 and
                      sec.fname eq bnmenu.fname and
                      sec.sts ne 9) /*or ofc1 = "root"*/ then do:
  if g-ofc eq "alechi" then txt = g-fname.
  if bnmenu.ntty ne 9999 then do:
    run set_title.p (bnmenu.fname,"",g-mdes).
    if search(bnmenu.proc + ".r") ne ? then do:
      hide all no-pause.
      run f_ofcp.r (bnmenu.fname, false).
      IF MENU_CONNECT_DBLIST(bnmenu.fname, 1) = 0 THEN  do:
        run value(bnmenu.proc).
        if g-ofc = "adm" or g-ofc = "innkra" then do:
          run resize_screen.p (25,80, output ok).
        end.
      end.
      delete_objects(). /* Chistka objectov i lishnih podkljuchenij */
      
      on PF4 end-error.
      pause before-hide.
      run f_ofcp.r ("", false).
    end.
    else do:
      message "Данная программа не доступна !".
      pause 3.
      hide message no-pause.
    end.
  end.
  else do:
    run set_title.p (bnmenu.fname,"-S",g-mdes).
    if search(stdr_run) ne ? then do:
      hide all no-pause.
      run f_ofcp.r (bnmenu.fname, false).
      unix silent value(stdr_run + " " + bnmenu.proc) no-echo.
      pause 0 before-hide.
      run f_ofcp.r ("", false).
    end.
    else do:
      message "Данная программа не доступна ! " stdr_run.
      pause 3.
      hide message no-pause.
    end.
  end.
end.
else do:
  display ms1 with frame ms1.
  run unaut_log(bnmenu.fname).
  pause 4 no-message.
  hide frame ms no-pause.
end.
end procedure.
