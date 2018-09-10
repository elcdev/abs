def shared var key_edit as log.
def shared var ofc like ofc.ofc.
def var tofc as char.
def var r as recid.
def var s as char.
def var nam as char format "x(40)" no-undo.
def var ok as log init no.
def var ques as log.
def var nofc as int64.
def var bra as int64 format "zzz".
def var titl as char format "x(45)" no-undo.
def var brades as char format "x(40)" .
def var cfstr as char format "x(5)" no-undo.
def var rmostr as int64 format ">" no-undo.
def var accstr as char format "x(20)" no-undo.
def var ofcmn as char extent 8 no-undo.
def var expdt as date extent 8.
def var ofchl as char extent 6 no-undo.
def var expdh as date extent 6.
def var sts as log format "Active/Deactivated".
def var frn as log init no.
def var fr_bra as int64.
def var email as char.
def var i as int64.
def buffer bofc for ofc.
def var quesd as log.
def var k as int64.
def var kmax as int64 init 7.
def var chgcif as int64 format "z".
def var dept as int64 format "zzzz".
def var bdt as date format "99/99/9999".
def var pss as char format "x(12)".
def var blk_key as char format "x(1)".
def var ok_key as log.
def var sx as char format "x(1)".
def var ch as char.
def var ms as char extent 2.
def var dat0 as date.
def var nxdat as dat.
def var sch as char format "x(78)".
def var cbankPerson AS bankPerson NO-UNDO.
cbankPerson = NEW bankPerson().
def query q for ofc.
def browse b query q 
    disp ofc.name    format "x(30)" label "User's name, surname"
         ofc.chrgbus format "x(12)" label "Personal code"
         with 5 down scrollable no-box. 
form b with frame f centered row 4.
define query crcq for ofc,bra,company scrolling.
define browse crcb query crcq no-lock
    display ofc.ofc ofc.name format "x(24)" label "NAME,SURNAME"
    with 16 down scrollable title " LIST OF USERS ".
    
form            
        ofc.ofc label "OFFICER" /* space(2) */
        ofc.chrgbus no-label format "x(12)" 
        ofc.bdt no-label format "99/99/9999" skip
        ofc.name label "Name" format "x(32)" skip 
        ofc.tit label "Position" format "x(32)" skip
        bra.bra label "Place" space(3)
        ofc.dpt label "Division" skip
        company.name format "x(39)" no-label skip
        ofc.expr[5] label "CIF veidi" format "x(5)" 
        space(1) ofc.auxint1 format "z" label "Change" skip
        ofc.expr[4] label "Citi parametri" format "x(22)" skip
        sts label "Stavoklis" skip
        email label "E-pasts" format "x(30)" skip
        with overlay row 3 column 40 frame tpri side-labels
        title " USER'S INFORMATION ".
        
form    
        ofc label "OFFIC" pss no-label format "x(12)" 
        bdt no-label format "99/99/9999" skip
        nam label "Vards" format "x(32)" skip
        titl label "Amats" format "x(32)" skip
        bra label "Vieta" space(3)
        dept label "Nodala" skip
        brades format "x(39)" no-label skip
        cfstr label "CIF veidi" format "x(5)" space(1)
        chgcif format "z" label "Change"
        validate(chgcif ge 0 and chgcif le 1,"")
        accstr label "Citi parametri" format "x(22)" skip
        sts label "Stavoklis" skip
        email label "E-pasts" format "x(30)"
        validate(index(email,"@") <> 0 and
                 index(email,".") <> 0,
                 "Неверно введен e-pasts !") skip         
        with overlay row 3 column 40 frame tpri1 side-labels
        title " LIETOT┘JA INFORM┘CIJA ".
email:width in frame tpri1 = 30.
email:format in frame tpri1 = "x(50)".
    
form
    ofc label  "OFFICER"  at 2 nam label "Vards,uzvards" at 20 skip
    titl label "  Amats" at 2 skip
    bra label  "  Vieta" at 2 brades no-label at 16 skip
    cfstr label "CIF veidi" format "x(5)" space(1)
    chgcif format "z" label "Change" skip
    accstr label "Citi parametri" format "x(20)" skip
    sts label "St√voklis" at 2 
    with frame dd side-labels row 5 centered color messages overlay
    top-only.

form crcb help 
"Ins-Add Enter-Edit Del-Delete F5-STAMP F6-HOLD F7-Rez/Ner/Alga"
with frame crcf row 3 /* centered */ overlay no-box.
{prg_head.f}.
on any-printable of b do:
    sch = caps(sch + chr(lastkey)).
    find first ofc where ofc.ofc begins "zz_" and ofc.name begins sch 
    no-lock use-index ofc no-error.
    if available ofc then do:
        reposition q to recid recid(ofc).
        message sch.
    end.
    else sch = substr(sch,1,length(sch) - 1).
end.
on backspace of b do:
    sch = substr(sch,1,length(sch) - 1).
    find first ofc where ofc.ofc begins "zz_" and ofc.name begins sch 
    no-lock no-error.
    if available ofc then reposition q to recid recid(ofc).
    message sch.
end.
on any-key of browse b do:
    if sch ne "" then do:
        sch = "".
        hide message no-pause.
    end.
end.
on value-changed of browse crcb do :
    hide frame dd no-pause.
    frn = ofc.ok.
    if ofc.stn = 0 then sts = yes. else sts = no.
    frn = ofc.ok.
    fr_bra = ofc.bra1.
    cbankPerson:Id = cbankPerson:GetPersonId_ByOfc(ofc.ofc).
    email = cbankPerson:cAttr:Item("email").
    run proc_disp.
end.    
/* Insert */
on insert of browse crcb do:
    if not key_edit then undo,leave.
    sch = "".
    r = recid(ofc).
    ofc = "".
    nam = "".
    dept = 0.
    sx = "".
    titl = "".
    bra = 0.
    brades = "".
    cfstr = "".
    chgcif = 0.
    rmostr = 0.
    accstr = "".
    sts = yes.
    bdt = ?.
    pss = "".
    blk_key = "".
    frn = no.
    fr_bra = 0.
    email = "".
    ok = no.
    ques = no.
    nam = "". 
    cr:
    repeat with frame dd while ok = no on endkey undo,leave :
        hide frame tpra1.
        hide frame tprh1.
        hide frame tpri1.
        hide frame crcf.
        view frame crcf.
        display ofc pss bdt nam titl dept bra brades cfstr chgcif 
        accstr sts email with frame tpri1.
        on PF3 of ofc
           DO:
              open query q
              for each ofc where ofc.ofc begins "zz_" no-lock by ofc.name.
              on return of browse b
                 do:
                    tofc = ofc.ofc.
                    disable all with frame f.
                    hide frame f.
                    enable all with frame crcf.
                    find first ofc where ofc.ofc = tofc no-lock no-error.
                    nam = ofc.name.
                    pss = ofc.chrgbus.
                    dept = ofc.dpt.
                    sx = ofc.titcd.
                    titl = ofc.tit.
                    bra = ofc.bra.
                    sch = "".
                    message sch.
                    disp nam pss dept titl bra with frame tpri1.
                 end.
              enable b with frame f.
              wait-for return of frame f.
           end.
        on pF4 of frame f
           do:
             disable all with frame f.
             hide frame f.
             enable all with frame crcf.
             view frame  tpri1.
             view frame crcf.
           end.
        update ofc help "User's name(F3 - for help)" 
        with frame tpri1.
        if ofc = "" then do :
            message "Not entered user's name !".
            pause 3.
            hide message no-pause.
            next cr.
        end.    
        find bofc where bofc.ofc = ofc no-lock no-error.
        if available bofc then do :
            message "User with entered name already exists !".
            pause 3.
            hide message no-pause.
            next cr.
        end.    
        update nam help "Nosaukums" with frame tpri1.
        update /*bdt*/ pss with frame tpri1.
        bdt = date(int(substr(pss,3,2)),
                   int64(substr(pss,1,2)),
                   int64(substr(pss,5,2)) + 1900) no-error.
        if pss ne "" and
         ( /* bdt eq ? or */ length(pss) ne 12 ) then do :
            message "Неверно указан персональный код !".
            pause 3.
            hide message no-pause.
            next cr.
        end.
        if pss ne "" then do:
            ok_key = no.
            run pk_chk.r(pss,output ok_key).
            if not ok_key then do:
                message "Неверно указан персональный код !".
                pause 3.
                hide message no-pause.
            end.
        end.
        find first bofc where bofc.ofc ne tofc and
                              bofc.chrgbus eq pss no-lock no-error.
        if available bofc and pss ne "" then do:
            message "Пользователь" bofc.ofc " - " bofc.name "уже заведен!".
            pause 3.
            hide message no-pause.
            next cr.
        end.
        if pss eq "" or not ok_key or nam eq "" then do :
            if nam = "" or
              can-find(first bofc where bofc.ofc ne ofc and
                                        bofc.name eq nam) then do :
                message "Неверно введено имя пользователя !".
                pause 3.
                hide message no-pause.
                next cr.
            end.
        end.
        update bdt with frame tpri1.
        if pss ne "" and
           (bdt eq ? or bdt > today)
        then do :
            message "Неверно указана дата рождения !".
            pause 3.
            hide message no-pause.
            next cr.
        end.
        update dept with frame tpri1.
        find first dept where dept.dept eq dept no-lock no-error.
        if not available dept then do:
            message "Неверно указан отдел !".
            pause 3.
            hide message no-pause.
            next cr.
        end.
        if sx eq "" then do:
            if index(nam," ") ne 0 then do:
                ch =  substr(nam,index(nam," ") - 1,1).
                if ( ch eq "a" or ch eq "e" or
                     ch eq "i" or ofc eq "telex" ) then sx = "F".
                else sx = "M".
            end.
        end.
        if titl eq "" then do:
            if sx eq "M" then titl = dept.tit[2].
            else titl = dept.tit[1].
        end.
        update titl label "Amats" with frame tpri1.
        if nam = "" then do :
            message "Не введена информация пользователя !".
            pause 3.
            hide message no-pause.
            next cr.
        end.
        update bra help "Место работы(филиал,расч.группа)" with frame tpri1.
        find bra where bra.bra = bra no-lock no-error.
        if not available bra then do :
            message "Не верно введен филиал(расч.группа) !".
            pause 3.
            hide message no-pause.
            next cr.
        end.
        find first company where company.logo = bra.addr[3] no-lock no-error.
        if available company then brades = company.name. 
        else brades = bra.name.
        display brades with frame tpri1.
        update cfstr help "Параметры работы с клиентами" 
        chgcif 
        help "1 - разрешено изменение параметров клиентов 0 - нет"
        accstr help 
        "1-9 - счета L-спец.возм.в депоз. H-Hold Y-карточки обр.подп. и т.д."
        with frame tpri1.
        update email with frame tpri1.
        pause 0 before-hide.
        hide frame tpri1.
        view frame tpri1.
        hide frame crcf.
        view frame crcf.
        message "Save ?" update ques.                
        if ques then do transaction :
           if tofc = "" then create ofc.
            else find first ofc where ofc.ofc = tofc no-error.
            assign ofc.ofc     = ofc
                   ofc.name    = nam
                   ofc.lang    = "RS"
                   ofc.tit     = titl
                   ofc.dpt     = dept
                   ofc.titcd   = sx
                   ofc.bra     = bra
                   ofc.who     = userid('bank')
                   ofc.whn     = today
                   ofc.expr[5] = cfstr
                   ofc.expr[4] = accstr
                   ofc.auxint  = rmostr
                   ofc.auxint1 = chgcif
                   ofc.tim     = time
                   ofc.bdt     = bdt
                   ofc.chrgbus    = pss
                   ofc.personCode = pss
                   ofc.auxstr  = caps(blk_key)
                   ofc.ok      = frn
                   ofc.bra1    = fr_bra
                   ofc.stn     = 0.
            /* tofc - старый логин, ofc - новый */
            for each ofchis where ofchis.ofc eq tofc:
              ofchis.ofc = ofc.
            end.
            run save_email.
            r = recid(ofc).
            find ofc where ofc.ofc = ofc no-lock no-error.
            leave cr.
        end.
        else undo cr,leave.
    end.
    close query crcq.
    open query crcq for each ofc no-lock ,first bra where bra.bra = ofc.bra
    no-lock,first company where company.logo = bra.addr[3] no-lock.
    enable crcb with frame crcf.
    find first ofc where recid(ofc) = r and
      can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
    if available ofc then do:
        reposition crcq to recid r.
        k = kmax.
        run proc_up(input-output k).
        run proc_dw(k).
        run proc_disp.
    end.
    else do :
        find first ofc where
          can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
        if available ofc then do :
            r = recid(ofc).
            reposition crcq to recid r.
            run proc_disp.
        end.
        else reposition crcq forward 1.
    end.
    hide frame tpri1 no-pause.
    view frame crcf.
    view frame tpri.
end.
/* Edit */
on return of browse crcb do:
    if not key_edit then undo,leave.
    sch = "".
    r = recid(ofc).
    find ofc where recid(ofc) = r no-error.
    if not available ofc then next.
    ok = no.
    ques = no.
    ofc = ofc.ofc.
    nam = ofc.name.
    dept = ofc.dpt.
    sx = ofc.titcd.
    titl = ofc.tit.
    bra  = ofc.bra.
    bdt  = ofc.bdt.
    pss  = ofc.chrgbus.
    blk_key = ofc.auxstr.
    frn  = ofc.ok.
    fr_bra = ofc.bra1.
    find bra where bra.bra = ofc.bra no-lock no-error.
    if available bra then do :
        find first company where company.logo = bra.addr[3] no-lock no-error.
        if available company then brades = company.name. 
        else brades = bra.name.
    end.
    else brades  = "".
    cfstr = ofc.expr[5].
    rmostr = ofc.auxint.
    chgcif = ofc.auxint1.
    accstr = ofc.expr[4] .
    frn = ofc.ok.
    cbankPerson:Id = cbankPerson:GetPersonId_ByOfc(ofc.ofc).
    email = cbankPerson:cAttr:Item("email").
    if ofc.stn = 0 then sts = yes. else sts = no.
    ok = no.
    ques = no.
    cr1:
    repeat with frame tpri1 while ok = no on endkey undo,leave :
        hide frame tpra1.
        hide frame tprh1.
        hide frame tpri1.
        hide frame crcf.
        view frame crcf.
        display ofc pss bdt nam titl dept bra brades cfstr chgcif 
        accstr sts email with frame tpri1.
        update nam help "Nosaukums" with frame tpri1.
        update pss with frame tpri1.
        bdt = date(int(substr(pss,3,2)),
                   int64(substr(pss,1,2)),
                   int64(substr(pss,5,2)) + 1900) no-error.
        if pss ne "" and
         ( /* bdt eq ? or */ length(pss) ne 12 ) then do :
            message "Неверно указан персональный код !".
            pause 3.
            hide message no-pause.
            next cr1.
        end.
        if pss ne "" then do:
            ok_key = no.
            run pk_chk.r(pss,output ok_key).
            if not ok_key then do:
                message "Неверно указан персональный код !".
                pause 3.
                hide message no-pause.
            end.
        end.
        find first bofc where bofc.ofc ne ofc and
                              bofc.chrgbus eq pss no-lock no-error.
        if available bofc and pss ne "" then do :
            message "Пользователь" bofc.ofc " - " bofc.name "уже заведен!".
            pause 3.
            hide message no-pause.
            next cr1.
        end.
        if pss eq "" or not ok_key or nam eq "" then do :
            if nam = "" or
              can-find(first bofc where bofc.ofc ne ofc and
                                        bofc.name eq nam) then do :
                message "Неверно введено имя пользователя !".
                pause 3.
                hide message no-pause.
                next cr1.
            end.
        end.
        update bdt with frame tpri1.
        if pss ne "" and
           (bdt eq ? or bdt > today)
        then do :
            message "Неверно указана дата рождения !".
            pause 3.
            hide message no-pause.
            next cr1.
        end.
        update dept with frame tpri1.
        find first dept where dept.dept eq dept no-lock no-error.
        if not available dept then do:
            message "Неверно указан отдел !".
            pause 3.
            hide message no-pause.
            next cr1.
        end.
        if sx eq "" then do:
            if index(nam," ") ne 0 then do:
                ch =  substr(nam,index(nam," ") - 1,1).
                if ( ch eq "a" or ch eq "e" or
                     ch eq "i" or ofc eq "telex" ) then sx = "F".
                else sx = "M".
            end.
        end.
        if titl eq "" then do:
            if sx eq "M" then titl = dept.tit[2].
            else titl = dept.tit[1].
        end.
        update titl label "Amats" with frame tpri1.
        if nam = "" then do :
            message "Не введена информация пользователя !".
            pause 3.
            hide message no-pause.
            next cr1.
        end.
        update bra help "Место работы(филиал,расч.группа)" with frame tpri1.
        find bra where bra.bra = bra no-lock no-error.
        if not available bra then do :
            message "Не верно введен филиал(расч.группа) !".
            pause 3.
            hide message no-pause.
            next cr1.
        end.
        find first company where company.logo = bra.addr[3] no-lock no-error.
        if available company then brades = company.name. 
        else brades = bra.name.
        display brades with frame tpri1.
        update cfstr help "Параметры работы с клиентами" 
        chgcif help "1 - разрешено изменение параметров клиентов 0 - нет"
        accstr help 
        "1-9 -счета L-спец.возм.в депоз. H-Hold Y,Z-карточки обр.подп. и т.д."
        with frame tpri1.
                
        update sts help "A - Aktivёt  D - Deaktivёt" with frame tpri1.
        update email with frame tpri1.
        message "Сохранить ?" update ques.                
        if ques then do:
          do transaction:
            find ofc where ofc.ofc = ofc exclusive-lock no-error.
            assign ofc.ofc     = ofc
                   ofc.name    = nam
                   ofc.tit     = titl
                   ofc.dpt     = dept
                   ofc.titcd   = sx
                   ofc.bra     = bra
                   ofc.who     = userid('bank')
                   ofc.whn     = today
                   ofc.expr[5] = cfstr
                   ofc.expr[4] = accstr
                   ofc.auxint  = rmostr
                   ofc.auxint1 = chgcif
                   ofc.tim     = time
                   ofc.bdt     = bdt
                   ofc.chrgbus = pss
                   ofc.personCode = pss
                   ofc.auxstr  = caps(blk_key)
                   ofc.ok      = frn
                   ofc.bra1    = fr_bra.
            if sts then ofc.stn = 0. else ofc.stn = 9.
            run save_email.
            
          end.
          /* run ofc_file.r. */
          r = recid(ofc).
          find ofc where ofc.ofc = ofc no-lock no-error.
          leave cr1.          
        end.
        else undo cr1,leave.
    end.
    hide frame tpri1 no-pause.
    close query crcq.
    open query crcq for each ofc no-lock ,first bra where bra.bra = ofc.bra
    no-lock,first company where company.logo = bra.addr[3] NO-LOCK.
    enable crcb with frame crcf.
    find first ofc where recid(ofc) = r and
      can-find(bra where bra.bra eq ofc.bra) no-lock no-error. 
    if available ofc then do:
        reposition crcq to recid r.
        k = kmax.
        run proc_up(input-output k).
        run proc_dw(k).
        run proc_disp.
    end.
    else do :
        find first ofc where
          can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
        if available ofc then do :
            reposition crcq to recid r.
            r = recid(ofc).
            run proc_disp.
        end.
        else reposition crcq forward 1.
    end.
    hide frame tpri1 no-pause.
    view frame crcf.
    view frame tpri.
end.

on recall of browse crcb do:
  if not key_edit then undo,leave.
  r = recid(ofc).
  run rna.
  find first ofc where recid(ofc) = r no-lock .
  run proc_disp.
end.
on delete-character of browse crcb do :
    if not key_edit then undo,leave.
    sch = "".
    hide frame tpri1 no-pause.
    r = recid(ofc).
    find ofc where recid(ofc) = r no-error.
    if not available ofc then next.
    ok = no.
    ques = no.
    ofc = ofc.ofc.
    nam = ofc.name.
    dept = ofc.dpt.
    sx = ofc.titcd.
    titl = ofc.tit.
    bra  = ofc.bra.
    bdt = ofc.bdt.
    pss = ofc.chrgbus.
    frn = ofc.ok.
    fr_bra = ofc.bra1.
    cbankPerson:Id = cbankPerson:GetPersonId_ByOfc(ofc.ofc).
    email = cbankPerson:cAttr:Item("email").
    find bra where bra.bra = ofc.bra no-lock no-error.
    if available bra then do :
        find first company where company.logo = bra.addr[3] no-lock no-error.
        if available company then brades = company.name. 
        else brades = bra.name.
    end.
    else brades  = "".
    cfstr = ofc.expr[5].
    rmostr = ofc.auxint.
    chgcif = ofc.auxint1.
    accstr = ofc.expr[4] .
    frn = ofc.ok.
    if ofc.stn = 0 then sts = yes. else sts = no.
    
    ok = no.
    ques = no.
    display ofc pss bdt nam dept titl bra brades cfstr chgcif 
    accstr sts email with frame tpri1.
    quesd = no.
    do while true on endkey undo,leave :
        message "Удалить ?" update quesd.
        leave.
    end.    
    hide frame tpri1 no-pause.
    if quesd = no then do :
        hide frame tpri1 no-pause.
        view frame crcf.
        view frame tpri.
    end.
    else do :
        hide frame tpri1 no-pause.
        delete ofc.
        find ofcmng where ofcmng.ofc = ofc no-error.
        if available ofcmng then delete ofcmng.
        find ofchol where ofchol.ofc = ofc no-error.
        if available ofchol then delete ofchol.
        /* run ofc_file.r. */
        close query crcq.
        open query crcq for each ofc no-lock ,first bra where bra.bra = ofc.bra
        no-lock,first company where company.logo = bra.addr[3] NO-LOCK.
        enable crcb with frame crcf.
        find first ofc where recid(ofc) = r and
          can-find(bra where bra.bra eq ofc.bra) no-lock no-error. 
        if available ofc then do:
            reposition crcq to recid r.
            k = kmax.
            run proc_up(input-output k).
            run proc_dw(k).
            run proc_disp.
        end.
        else do :
            find first ofc where
              can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
            if available ofc then do :
                r = recid(ofc).
                reposition crcq to recid r.
                run proc_disp.
            end.
            else reposition crcq forward 1.
        end.
        hide frame tpri1 no-pause.
        view frame crcf.
    end.     
    view frame crcf.
    view frame tpri.
    hide frame tpri1 no-pause.
end.
on end-error of browse crcb do :
    hide frame crcf no-pause.
    hide frame tpri1 no-pause.
    hide frame tpri no-pause.
    hide frame tpra1.
    hide frame tprh1.
end.
on any-printable of browse crcb do:
    sch = sch + lc(chr(lastkey)).
    hide frame tpri1 no-pause.
    find first ofc where ofc.ofc begins sch and
      can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
    if not available ofc then
      find first ofc where ofc.name matches "*" + sch + "*" and
        can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
    if not available ofc then
      find first ofc where ofc.chrgbus begins sch and
        can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
    if available ofc then do:
            r = recid(ofc).
            reposition crcq to recid r.
            if ofc.stn = 0 then sts = yes. else sts = no.
            run proc_disp.
            message sch.
    end.
    else do:
      sch = substr(sch,1,length(sch) - 1).
      find first ofc where ofc.ofc begins sch and
        can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
    end.
end.
on backspace of browse crcb do:
    sch = substr(sch,1,length(sch) - 1).
    hide frame tpri1 no-pause.
    find first ofc where ofc.ofc begins sch and
      can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
    if not available ofc then
      find first ofc where ofc.name matches "*" + sch + "*" and
        can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
    if not available ofc then
      find first ofc where ofc.chrgbus begins sch and
        can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
    if available ofc then do:
            r = recid(ofc).
            reposition crcq to recid r.
            if ofc.stn = 0 then sts = yes. else sts = no.
            run proc_disp.
    end.
    message sch.
end.
on any-key of browse crcb do:
    if sch ne "" then do:
        sch = "".
        hide message no-pause.
    end.
end.
open query crcq for each ofc no-lock,first bra where bra.bra = ofc.bra
no-lock,first company where company.logo = bra.addr[3] NO-LOCK.
enable crcb with frame crcf.
find first ofc where ofc.ofc = ofc /*frame-value*/ and
  can-find(bra where bra.bra eq ofc.bra) no-lock no-error. 
if available ofc then do:
    r = recid(ofc).
    reposition crcq to recid r.
    if ofc.stn = 0 then sts = yes. else sts = no.
    run proc_disp.
end.
else do :
    find first ofc where
      can-find(bra where bra.bra eq ofc.bra) no-lock no-error.
    if available ofc then do :
        r = recid(ofc).
        reposition crcq to recid r.
        if ofc.stn = 0 then sts = yes. else sts = no.
        run proc_disp.
    end.    
    else reposition crcq forward 1.
end.
wait-for end-error of crcb focus crcb.
DELETE OBJECT cbankPerson.

procedure proc_up.
def input-output  parameter i as int64.
def var j as int64.
def var r1 as recid.
r1 = recid(ofc).
do j = 1 to i :
    apply "UP" to browse crcb.
    if recid(ofc) eq r1 then do :
        i = j - 1.
        leave.
    end.
    else r1 = recid(ofc).
end.
end procedure.

procedure proc_dw.
def input parameter i as int64.
def var rw as recid.
def var j as int64.
do j =  1 to i :
    apply "DOWN" to browse crcb.
end.
end procedure.

procedure proc_disp :
    display ofc.ofc ofc.bdt ofc.chrgbus
    ofc.name ofc.tit ofc.dpt bra.bra company.name ofc.expr[5] 
    ofc.expr[4] 
    ofc.auxint1 email
    with frame tpri.
    color display messages ofc.ofc ofc.name company.name sts 
    with frame tpri.
end procedure.

procedure save_email.
def var temp_id as int64.
def var i_FirstName as char.
def var i_LastName as char.
def var pr_ind as int64.
temp_id = cbankPerson:GetPersonId_ByOfc(ofc.ofc).
if temp_id > 0 then do:
  cbankPerson:Id = temp_id.
  cbankPerson:cAttr:SetItem("email", email).
end.
else do:
  i_FirstName = trim(ofc.name).
  i_LastName = "".
  pr_ind = index(i_FirstName, " ").
  if pr_ind > 0 then do:
    i_LastName = substring(i_FirstName,pr_ind + 1).
    i_FirstName = substring(i_FirstName,1,pr_ind - 1).
  end.
  cbankPerson:CreateFromOfc(i_FirstName, i_LastName, ofc.chrgbus, ofc.bdt).
  temp_id = cbankPerson:GetPersonId_ByOfc(ofc.ofc).
  if temp_id > 0 then do:
    cbankPerson:Id = temp_id.
    cbankPerson:cAttr:SetItem("email", email).
  end.
  else message "Невозможно сохранить email для " ofc.ofc "!!!".
end.  
end procedure.
