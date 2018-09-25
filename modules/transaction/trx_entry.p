/*
def var baseCrc as int64 no-undo.
def var baseCcy as cha no-undo.
run base_crc.r(output baseCrc,output baseCcy).
def var expkey as log init no.
def var sgn as int64.
{sysc.f}
{mlaaad_cls.i}
define input parameter key as int64.

define variable deb  like jl.dam.
define variable kre  like jl.dam.
define variable j  as int64 format "9" initial 0.
define variable j1 as int64 format "9" initial 0.
define variable j2 as int64 format "9" initial 0.
define variable j3 as int64 format "9" initial 0.
define variable i1 as int64 format "9" initial 0.
define variable i2 as int64 format "9" initial 0.
define variable i3 as int64 format "9" initial 0.
define variable m  as int64 format "9" initial 0.
define variable m1 as int64 format "9" initial 0.
define variable m2 as int64 format "9" initial 0.
define variable k  as int64 format "9" initial 0.
define variable k1 as int64 format "9" initial 0.
define variable transaction_header as int64 format ">>>>>>>>>9".
define new shared variable s-jh as int64 format ">>>>>>>9".
def new shared var s-gl like gl.gl.
def new shared var s-crc like crc.crc.
def buffer bgl for gl.
def var lonkey as log init no.
define variable oldtrval like crc.crc.
define variable line as int64 format "9999".
define variable glkon like jl.gl.
define variable subl as character format "x(10)" /*case-sensitive*/ . /* by serkuz */
def var subliban as char format "x(21)" /* case-sensitive */ . /* by vadvas */
define variable kom as character format "x(65)" extent 3.
define variable val like jl.crc.
define variable dbt like jl.dam.
define variable krd like jl.cam.
define variable oldline like jl.ln.
define variable oldglkon like jl.gl.
define variable oldsubl like jl.acc.
define variable oldkom like jl.rem extent 3.
define variable oldval like jl.crc.
define variable olddbt like jl.dam.
define variable oldkrd like jl.cam.
define variable oldprizn like jl.dc.
define variable prizn like jl.dc.
define variable trval like transaction_header.crc.
define variable i as int64 initial 0.
define variable auxs as decimal format "->>>,>>>,>>>,>>>,>>9.99".
define variable atl1 as decimal format "->>>,>>>,>>>,>>>,>>9.99".
define variable totost as decimal format "->>>,>>>,>>>,>>>,>>9.99".
define variable atl like aaa.cbal.
define variable ost7 as decimal format "->>>,>>>,>>>,>>>,>>9.99".
define variable mes as character format "x(78)".
define variable mes2 as character format "x(78)".
define variable mesx as character format "x(78)".
define variable krkon like aaa.aaa.
define variable overd like aaa.aaa.
define variable dop1 as int64 initial 0.
define variable short like jl.aah.
define variable aux7 like jl.aah.
define variable aux8 like jl.aah.
define variable aux9 like jl.aah.
define variable dop_par like jl.dam.
define variable aux like jl.dam.
define variable sost as int64.
define variable sost2 as int64.
define variable sost3 as int64 initial 0.
define variable sum_rem like jl.dam initial 0.0.
define variable ques2 as logical format "Yes/No" initial no.
def var casgl like gl.gl.
def var brcash like gl.gl.
def var nsgl like gl.gl.
def var pcod as int64 format "999".
def var keyres as log init no.
def var keynores as log init no.
def var prefix as char format "!(2)".
def var cndes as char format "x(25)".
def var chbr as int64.
def var k2 as int64.
def var ubkey as log init no.
def var debx as dec extent 50.
def var krex as dec extent 50.
def var ost7x as dec.
def var strx as char.
def var mdat as date.
def var dx1 as date.
def var dx2 as date.
def var nam as char.
def var ques1 as log.
def var codkey as log.
def var card as log.
def var srvkey as log.
def var sblxx as char.
def var idepoind as int.
def var cbnk as sysbnk.
def var logstr as char.
cbnk = new sysbnk().
def buffer s_jl for bank.jl.
def buffer s_gl for bank.gl.
def buffer s_crc for bank.crc.
def var saldo as decimal extent.
find last crc no-lock no-error.
extent(saldo) = crc.crc.
*/
define input parameter key as int64.

define variable deb  AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define variable kre  AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define variable atl  AS DECIMAL FORMAT "z,zzz,zzz,zzz,zz9.99-".
define variable debet AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define variable credit AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define new shared variable s-jh as int64 format ">>>>>>>>>9".
define variable line as int64 format "9999".
define variable glkon AS INT64 FORMAT "zzzzzzz9".
define variable account as character format "x(12)" .
define variable transaction_header as int64 format ">>>>>>>>>9".
define variable currency AS CHARACTER FORMAT "x(3)".
define variable account_name as character.
define variable details as character format "x(65)".
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


/*
form transaction_header no-label at 1 transaction_header.jdt no-label at 12
    transaction_header.who no-label at 22 with frame ccc row 2 overlay
    title "Tranz√kc.  Datums   Izpild.".
form transaction_header.cif no-label transaction_header.party no-label  format "x(34)"
   /*  pcod no-label space(6) */ trval no-label
    with frame cc2 row 2 column 32  overlay
    title "Klients       Oper√cija                  Val╜ta".
form atl label "ATL" to 27 deb label "DR" to 54 kre label "CR" to 79
    with frame cc1 row 5 side-labels overlay no-box.
form line no-label glkon no-label gl.sname no-label val no-label
    subliban no-label skip                                     /* by vadvas */
    nam no-label format "x(33)" dbt no-label at 35 krd no-label at 57 skip
    with frame cc3 scroll 4 4 down  overlay title
"LN  Konts  Konta nosaukums     Val Subkonts      Debets              Kred╗ts  "
.
form
    kom[1] label "Apraksts" at 2 skip
    kom[2] no-label at 12 skip
    kom[3] no-label at 12 skip
    with frame cc4 row 16 overlay side-labels no-box.
*/
/*    
find sysc where sysc.sysc = "SRVPRN" no-lock no-error.
if available sysc then srvkey = sysc.loval. else srvkey = no.
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then casgl = sysc.inval. else casgl = 101000.
find sysc where sysc.sysc = "BRCASH" no-lock no-error.
if available sysc then brcash = sysc.inval. else brcash = 105000.
find sysc where sysc.sysc = "RMINS" no-lock no-error.
if available sysc then nsgl = sysc.inval. else nsgl = 454000.
find sysc where sysc.sysc = "CHBR" no-lock no-error.
if available sysc then chbr = sysc.inval. else chbr = 1.
find ofc where ofc.ofc = g-ofc no-lock no-error.
if index(ofc.expr[5],"X") = 0 then codkey = no. else codkey = yes.
if index(ofc.expr[4],"C") ne 0 then card = yes. else card = no.
hide message no-pause.
*/

if key = 2 then do :
    
    update transaction_header validate (can-find(transaction_header where transaction_header.header_id = transaction_header ),
    "Не правильно указан номер транзакции !") 
    help "Номер транзакции (F2 - HELP)" with frame ccc.
    
    find FIRST transaction_header where transaction_header.header_id = transaction_header no-error.
    s-jh = transaction_header.
    
    display transaction_header.balance_date transaction_header.create_user 
    transaction_header.deal_number with frame ccc.
    
    for each transaction_line WHERE transaction_line.header_id = transaction_header.header_id no-lock use-index header_id :
        line = transaction_line.line.
        glkon = transaction_line.gl.
        currency = transaction_line.currency.
        account = transaction_line.account.
        details = transaction_line.details.
        debet = transaction_line.debet.
        credit = transaction_line.credit.
        find FIRST gl WHERE gl.gl = transaction_line.gl no-lock no-error.
        if gl.subled <> "" then do :
            FIND FIRST account WHERE account.account = transaction_line.account NO-LOCK NO-ERROR.
            IF AVAILABLE account THEN account_name = account.description.
        END.   
        else account_name = "".
        display line glkon gl.short_name currency account with frame cc3. 
        display details with frame cc4.
        display account_name debet credit with frame cc3.
        deb = deb + debet.
        kre = kre + credit.
        atl = deb - kre.
        display atl deb kre with frame cc1.
        down with frame cc3.
    end.
end.
PAUSE.
/*
if key = 1 then do :
    run transaction_header_maker(0,"",output transaction_header).
    s-transaction_header = transaction_headerx.
    find transaction_header where transaction_header.transaction_header = s-transaction_header no-error.
    display transaction_headerx with frame ccc.
    display transaction_header.balance_date transaction_header.who with frame ccc.
    display transaction_header.cif transaction_header.party with frame cc2.
    trval = transaction_header.crc.
    display trval with frame cc2.
    display atl deb kre with frame cc1.
    view frame cc3.
    view frame cc4.
    view frame cc5.
end.
*/
/*
repeat while i2 = 0 on endkey undo,retry :
    repeat while k = 0 on endkey undo,leave :
        s-transaction_header = transaction_header.
        find transaction_header where transaction_header.transaction_header = s-transaction_header no-error.
        {mesg.i 409} update j.
        if j = 1 then do :
            if transaction_header.jdt < g-today then do :
                message
                "Это не сегодняшняя транзакция ! Ее нельзя редактировать !".
                pause 3.
                hide message no-pause.
            end.
            else if transaction_header.auxint = 2 then do :
                message 
"Операция создана в режиме кассовых транзакций! Коррекция недопустима!".
                pause 3.
                hide message no-pause.
            end.
            else if transaction_header.auxint = 1 then do :
                message 
"Операция создана в режиме внутрибанковских транзакций! Коррекция недопустима!".
                pause 3.
                hide message no-pause.
            end.
            else do :
                if transaction_header.sts = 6 and g-ofc <> "root" then do :
                    message
                    "Это транзакция отштампована ! Ее нельзя редактировать !".
                    pause 3.
                    hide message no-pause.
                end.
                else do :
                    if g-ofc <> "root" and g-ofc <> transaction_header.who then do :
                        message
                        "Это не Ваша транзакция ! Ее нельзя редактировать !".
                        pause 3.
                        hide message no-pause.
                    end.
                    else do :
                        if key = 1 then do  :
                            update trval
                            validate (can-find(crc where crc.crc = trval)
                            or trval = 0 or trval = oldtrval,
                            "Не правильно указана валюта !")
                            with frame cc2.
                            do transaction:
                                find transaction_header where transaction_header.transaction_header = s-transaction_header no-error.
                                assign transaction_header.crc = trval.
                            end.
                            oldtrval = trval.
                        end.
                        if key = 2 then do while k1 = 0 :
                            update trval
                            validate (can-find(crc where crc.crc = trval)
                            or trval = 0 or trval = oldtrval,
                            "Не правильно указана валюта !")
                            with frame cc2.
                            if trval = oldtrval or trval = 0 then 
                            do transaction:
                                find transaction_header where transaction_header.transaction_header = s-transaction_header no-error.
                                assign transaction_header.crc = trval.
                                assign transaction_header.tty = pcod.  
                                oldtrval = trval.
                                k1 = 1.
                            end.
                            else do :
                                message "Не верно указана валюта !!!".
                                pause 2.
                                hide message no-pause.
                            end.
                        end.
                        k1 = 0.
                        repeat on endkey undo,leave :
                            deb = 0.0.
                            kre = 0.0.
                            for each jl of transaction_header where (jl.auxint = 0 or srvkey) 
                            no-lock use-index transaction_header :
                                /* andsus */
                                if jl.ln GT 999 and (jl.acc begins "8" or
                                jl.acc begins "5") and
                                substring(jl.acc,10,1) eq "S" then next.
                                
                                deb = deb + jl.dam.
                                kre = kre + jl.cam.
                            end.
                            atl = deb - kre.
                            display atl deb kre with frame cc1.
                            m1 = 0.
                            m = 0.
                            line = int64("").
                            glkon = 0.
                            s-gl = 0.
                            ost7x = 0.
                            val = 0.
                            s-crc = 0.
                            subl = "".
                            /* by vadvas */
                            subliban = "".
                            lonkey = no.
                            if atl > 0.0 then do :
                                krd = atl.
                                dbt = 0.0.
                            end.
                            else  do :
                                dbt = - atl.
                                krd = 0.0.
                            end.
                            if key = 2 or j1 <> 0 then do :
                                down with frame cc3.
                                j1 = 1.
                            end.
                            set line validate(line < 1000,"") 
                            with frame cc3.
                            j1 = 1.
                            if line <> int64("") then do :
                                find jl where jl.transaction_header = transaction_header.transaction_header and
                                jl.ln = line no-error.
                                if available jl then do :
                                    
                                    if can-find(first bjl where bjl.transaction_header = transaction_header.transaction_header and bjl.ref1 matches 
                                    "*mak_jlmn_CAN_BATCH_WITH_TWO*") then do:
                                        message "Нельзя исправить линию. Необходимо полностью удалить транзакцию!".
                                        pause 3.
                                        hide message no-pause.
                                        up with frame cc3.
                                        undo,retry.
                                    end.
                                    
                                    dop1 = 1.
                                    line = jl.ln.
                                    glkon = jl.gl.
                                    val = jl.crc.
                                    subl = jl.acc.
                                    /* by vadvas */
                                    subliban = jl.acc.
                                    find aaa where aaa.aaa = subl no-lock no-error.
                                    if available aaa and aaa.ref <> "" then
                                      subliban = aaa.ref.
                                    kom[1] = jl.rem[1].
                                    kom[2] = jl.rem[2].
                                    kom[3] = jl.rem[3].
                                    dbt = jl.dam.
                                    krd = jl.cam.
                                    oldglkon = jl.gl.
                                    oldval = jl.crc.
                                    oldsubl = jl.acc.
                                    oldkom[1] = jl.rem[1].
                                    oldkom[2] = jl.rem[2].
                                    oldkom[3] = jl.rem[3].
                                    oldprizn = jl.dc.
                                    olddbt = jl.dam.
                                    oldkrd = jl.cam.
                                    short = jl.aah.
                                end.
                                else do :
                                    dop1 = 0.
                                    glkon = 0.
                                    val = baseCrc.
                                    subl = "".
                                    /* by vadvas */
                                    subliban = "".
                                    sost2 = 1.
                                end.
                            end.
                            else do :
                                find last jl where jl.transaction_header = s-transaction_header
                                and jl.ln < 1000 
                                use-index transaction_headerln no-lock no-error.
                                if available jl then
                                line = jl.ln + 1.
                                else line = 1.
                                if line = 1000 then do :
                                    message "Номер строки превышает 999 !".
                                    pause 3.
                                    hide message no-pause.
                                    up with frame cc3.
                                    undo,retry.
                                end.
                                display line  with frame cc3.
                                glkon = 0.
                                val = baseCrc.
                                subl = "".
                                /* by vadvas */
                                subliban = "".
                                sost2 = 1.
                                dop1 = 0.
                            end.
                            repeat while m = 0 :
                                update glkon 
                                validate(can-find(gl where gl.gl = glkon),
                                "Не правильно указан счет главной книги !!!")
                                with frame cc3.
                                find gl where gl.gl = glkon no-lock no-error.
                                if available gl then do :
                                    if gl.sts = 9 
                                    or (glkon = nsgl and trval ne baseCrc) then do :
                                        message "Не активный счет !!!".
                                        pause 2.
                                        hide message no-pause.
                                    end.
                                    else if glkon = casgl then do :
                                        find ofc where ofc.ofc = g-ofc no-lock
                                        no-error.
                                        if ofc.bra > chbr then do :
                                            message
                                        "Вы не можете использовать этот счет !".
                                            pause 3.
                                            hide message no-pause.
                                        end.
                                        else m = 1.
                                    end.
                                    else m = 1.
                                end.
                                else do :
                                    up with frame cc3.
                                end.
                            end.
                            if m = 1 then do :
                                find gl where gl.gl = glkon no-lock no-error.
                                if available gl then do :
                                    display gl.sname with frame cc3.
                                    if trval = 0 then do :
                                        repeat while j2 = 0 :
                                            update val
                                    validate (can-find(crc where crc.crc = val),
                                            "Не верно указана валюта !!!") 
                                            with frame cc3.
  
  ques1 = yes.
  find first crc where crc.crc eq val no-lock no-error.
  if available crc and crc.del then do:
    ques1 = no.
    message "Валюта" crc.code + "," + crc.des
            "является неактивной валютой! Продожить?" update ques1.
  end.
  if ques1 then j2 = 1.
  
                                        end.
                                        if j2 = 0 then do :
                                            up with frame cc3.
                                        end.
                                        else j2 = 0.
                                    end.
                                    else do :
                                        val = trval.
                                        display val with frame cc3.
                                    end. 
                                find crc where crc.crc = val no-lock no-error.
                                    repeat while i = 0 on endkey undo ,leave :
                                        s-gl = glkon.
                                        s-crc = val.
                                        /* by vadvas */
                                        {un_sub+3.i
                                        &frame=cc3
                                        &subled=subl
                                        &subupdt=subliban
                                        &crc=val
                                        &cod=crc.code
                                        &gl=glkon
                                        &chk=no
                                        &amt=dbt
                                        &en=1
                                        }
                                        /*
                                        {un_glx.f}.
                                        */
                                        if gl.subled = "CIF" then do :
                                            find aaa where aaa.aaa = subl 
                                            no-lock no-error.
                                            if available aaa then do :
                                                find cif of aaa 
                                                no-lock no-error.
                                                if cif.type = "X" then 
                                                nam = cif.cif.
                                                else nam = cif.sname.
                                            end.
                                            else nam = "".
                                        end. 
                                        else if gl.subled = "LON" then do :
                                            find lon where lon.lon = subl 
                                            no-lock no-error.
                                            if available lon then do :
                                            find cif where cif.cif = lon.cif 
                                                no-lock no-error.
                                                if cif.type = "X" then 
                                                nam = cif.cif.
                                                else nam = cif.sname.
                                            end.
                                            else nam = "".
                                        end. 
                                        else if gl.subled = "ARP" then do :
                                            find arp where arp.arp = subl 
                                            no-lock no-error.
                                        if available arp then nam = arp.des.
                                            else nam = "".
                                        end. 
                                        else if gl.subled = "FUN" then do :
                                            find fun where fun.fun = subl 
                                            no-lock no-error.
                                        if available fun then nam = fun.rem.
                                            else nam = "".
                                        end. 
                                        else if gl.subled = "DFB" then do :
                                            find dfb where dfb.dfb = subl 
                                            no-lock no-error.
                                            if available dfb then 
                                            nam = dfb.name.
                                            else nam = "".
                                        end. 
                                        else if gl.subled = "AST" then do :
                                            find ast where ast.ast = subl 
                                            no-lock no-error.
                                            if available ast then 
                                            nam = ast.name.
                                            else nam = "".
                                        end. 
                                        else if gl.subled = "EPS" then do :
                                            find eps where eps.eps = subl 
                                            no-lock no-error.
                                            if available eps then 
                                            nam = eps.des.
                                            else nam = "".
                                        end. 
                                        else nam = "".
                                        display nam with frame cc3.
                                    end.
                                    if i = 0 then do :
                                        up with frame cc3.
                                        leave.
                                    end.
                                    else i = 0.
                                end.
                                else do :
                                    up with frame cc3.
                                end.
                                repeat while j3 = 0 :
                                    update kom with frame cc4.
                                    j3 = 1.
                                end.
                                if j3 = 0 then do :
                                    up with frame cc3.
                                    leave.
                                end.
                                else j3 = 0.
                                blk:
                                repeat while m1 = 0 on endkey undo,leave :
                                    find crc where crc.crc = val 
                                    no-lock no-error.
                                    update dbt
                                    validate
                                    (dbt ge 0.0 ,
                                    "Должно быть > 0 !" )
                                    with frame cc3.
                                    dbt = round(dbt,crc.decpnt).
                                    display dbt with frame cc3.
                                    if dbt = 0.0 then do :
                                        update krd
                                    validate (krd ge 0.0 ,"Должно быть > 0 !" )
                                        with frame cc3.
                                        krd = round(krd,crc.decpnt).
                                        display krd with frame cc3.
                                        if krd > 0.0 then do :
                                            if gl.subled = "CIF" then do :
                                                find baa3 where 
                                                baa3.aaa = subl no-lock 
                                                no-error.
                                                if available baa3 then do :
                                                    ost7x = 
                                                    baa3.cr[1] - baa3.dr[1].
                                                    find lgr where lgr.lgr =
                                                    baa3.lgr no-lock no-error.
                                                    if lgr.led = "CDA" then do :
                                                        run cda_chkc.
                                                    end.
                                                    else do :
                                                        dbt = 0.0.
                                                        prizn = "C".
                                                        display dbt 
                                                        with frame cc3.
                                                        m1 = 1.
                                                    end.   
                                                end.
                                            end.
                                            else do :
                                                dbt = 0.0.
                                                prizn = "C".
                                                display dbt with frame cc3.
                                                m1 = 1.
                                            end.    
                                        end.
                                    end.
                                    else do :
                                        if gl.subled = "CIF" then do :
    find ofc where ofc.ofc = g-ofc no-lock no-error.
    find bra where bra.bra = ofc.bra no-lock no-error.
    find baa2 where baa2.aaa = subl no-lock no-error.
    if not available baa2 then undo,next blk.
    find lgr where lgr.lgr = baa2.lgr no-lock no-error.
    find cif where cif.cif = baa2.cif no-lock no-error.
    if cif.type = "X" and codkey = no then do :
        hide message no-pause.
        message 
        "Вы не имеете права проводить дебетовые операции с кодовыми счетами !".
        pause 3.
        hide message no-pause.
        undo,next blk.
    end.
    if cif.expdt lt g-today then do :
        message "Закончился срок доверенности ! Продолжать ?" update ques1.
        if ques1 = no then undo,next blk.
    end.
    if (bra.tim = 9 and baa2.bra ne ofc.bra) or baa2.auxint1 = 1
       or (cif.prefix eq 'LV' and not ofc.expr[3] matches '*R*')
       or (cif.prefix ne 'LV' and not ofc.expr[3] matches '*N*')
     then do :
      IF NOT cbnk:seccif_uni(cif.cif, g-ofc) THEN DO:
        message "Вы не имеете права дебетовать этот счет !".
        pause 5.
        hide message no-pause.
        undo,next blk.
      END.   
    end.
    find first aas where aas.aaa eq baa2.aaa and
                         aas.sic eq "SC" and
      ( aas.chkdt le g-today or aas.chkdt eq ? ) no-lock no-error.
    if available aas then do:
        message
          "Klientam aizliegts veikt skaidras naudas izmaksu oper√cijas !".
        pause 5. 
        hide message no-pause. 
        undo,next blk. 
    end. 
    if lgr.led = "CDA" and 
        ((baa2.regdt > 05/14/2000 and baa2.pass = "T") 
        or baa2.pass = "K") and baa2.expdt gt g-today then do :
        find dpdeal where dpdeal.dpdeal = baa2.aaa no-lock no-error.
        if available dpdeal then do :
          if dpdeal.grp = 53 then do:
              find unicat where unicat.catid  = "BERNDEPIZM_B"
                            and unicat.field1 = g-ofc no-lock no-error.
              if not available unicat then do:
                  message
              "Создание транзакции выплаты по данному депозиту запрещено!".
                  pause 5.
                  hide message no-pause.
                  undo,next blk.
              end.
              prizn = "D".
              krd = 0.0.
              display krd with frame cc3.
              m1 = 1.
          end.
          else do:
            message 
            "Воспользуйтесь другой программой для выплаты данного депозита !".
            pause 5.
            hide message no-pause.
            undo,next blk.
          end.
        end.
        else do :
            prizn = "D".
            krd = 0.0.
            display krd with frame cc3.
            m1 = 1.
        end.
    end.
    else do :
        prizn = "D".
        krd = 0.0.
        display krd with frame cc3.
        m1 = 1.
    end.
                                        end.    
                                        else do :
                                            prizn = "D".
                                            krd = 0.0.
                                            display krd with frame cc3.
                                            m1 = 1.
                                        end.
                                    end.
                                end.
                            end.
                            else do :
                                up with frame cc3.
                            end.
                            /* операция с VIVA. by ingsaf */
                            if subl begins "7" and not card then do:
                                find first baa4 where baa4.aaa eq subl
                                no-lock no-error.
                                if avail baa4 and baa4.grp eq 2 and 
                                dbt ne 0.0 then do:
                                    /* дебет VIVA карты без прав на операцию */
                                    message 
                            "Вы не можете проводить дебет VIVA карты !".
                                    pause 3.
                                    hide message no-pause.
                                    m = 0.
                                end.
                            end.
                            if m = 1 and m1 = 1 then do :
                                if sost2 = 1 then do :
                                    /* objazatelnaja proverka na polozhitelnoje saldo,
                                       summarnij debet ne mozhet bit otricatelnim!!!
                                       by dmikai
                                    */
                                    saldo = 0.0.
                                    for each s_jl where s_jl.transaction_header = s-transaction_header exclusive-lock:
                                      if dop1 = 1 then do:
                                        /* ignorirujem liniju, kotoriju budem udaljat */
                                        if s_jl.ln = line then next.
                                      end.
                                      /* ne uchitivajem zabalans */
                                      find first s_gl where s_gl.gl = s_jl.gl no-lock.
                                      if s_gl.totgl = 600000 or s_gl.totgl = 300000 then do:
                                        next.
                                      end.
                                      saldo[s_jl.crc] = saldo[s_jl.crc] + s_jl.dam - s_jl.cam.
                                    end.
                                    /* dobavljajem novuju liniju */
                                    find first s_gl where s_gl.gl = glkon no-lock.
                                    if not (s_gl.totgl = 600000 or s_gl.totgl = 300000) then do:
                                      saldo[val] = saldo[val] + dbt - krd.
                                    end.
                                    for each s_crc no-lock:
                                      if saldo[s_crc.crc] < 0 then do:
                                        mes2 = "Nedrikst tais╗t oper√cijas ar negativo saldo!".
                                        if g-today > date(4,1,2014) then do:
                                          sost2 = 0.
                                        end.
                                        else do:
                                          message mes2.
                                          unix silent value(substitute("email andsus@norvik.eu -b -s '&1,&2,&3'",g-ofc,s-transaction_header,dbt - krd)).
                                          readkey pause 5.
                                        end.
                                        leave.
                                      end.
                                    end.
                                end.
                                if sost2 = 1 and dop1 = 1 then do :
                                    /* Откат старой линии */
                                    sost2 = 0.
                                    mes2 = "".
                                    cr:
                                    do transaction:
                                       /* ALEZHU Sohranenije rasshivrovki */
                                       if jlpz_chk_gl(glkon) then
                                        do:
                                          for each jlpz where jlpz.transaction_header = transaction_header.transaction_header 
                                                   and jlpz.ln = line
                                                   use-index transaction_header:
                                            jlpz.ln = - line.
                                          end.
                                        end.
                                        run del_jlmn.r(transaction_header.transaction_header,line,yes,yes,
                                        output sost2,output mes2).
                                        if sost2 = 0 then do :
                                            message mes2.
                                            pause 5.
                                            undo cr.
                                        end.
                                    end.    
                                    /*
                                    {ot_jl2x.f}.
                                    */
                                end.
                                if sost2 = 1 then do :
                                    cr2:
                                    do transaction:
                                        run mak_jlxf.p (transaction_headerx,glkon,subl,line,
                                        dbt,krd, kom[1],kom[2],kom[3],
                                        prizn,val,output sost,output mes,
                                        output aux7,output aux8,output aux9).
                                        if sost = 0 then do :
                                            message mes.
                                            pause 2.
                                            hide message no-pause.
                                            up with frame cc3.
                                            undo cr2. 
                                            
                                            /*
                                            find jl where jl.transaction_header = s-transaction_header and 
                                            jl.ln = line no-error.
                                            if available jl then delete jl.
                                            */
                                            if dop1 = 1 then do :
                                                dop1 = 0.
                                                run mak_jlxf.p (transaction_headerx,oldglkon,
                                                oldsubl,line,olddbt,oldkrd,
                                                oldkom[1],oldkom[2],
                                                oldkom[3],oldprizn,oldval,
                                                output sost,output mes,output aux7,
                                                output aux8,output aux9).
                                                if sost = 0 then do :
                                                    message mes.
                                                    pause 2.
                                                    hide message no-pause.
                                                    undo cr2.
                                                    /*
                                                    find jl where jl.transaction_header = s-transaction_header and
                                                    jl.ln = line no-error.
                                                    if available jl then delete jl.
                                                    */
                                                end.
                                            end.
                                            
                                        end.
                                    end.
                                    
                                end.
                                
                                if sost2 = 0 then do:
                                    message mes2.
                                    pause 3.
                                    hide message no-pause.
                                    up with frame cc3.
                                 end.
                                else
                                 do:
                                    if jlpz_chk_gl(glkon) then
                                     do:
                                        /* ALEZHU VOSSTANOVLENIJE JPLZ */
                                        for each jlpz where jlpz.transaction_header = transaction_header.transaction_header 
                                                   and jlpz.ln = - line 
                                                   use-index transaction_header:
                                            jlpz.transaction_header = transaction_header.transaction_header.
                                            jlpz.ln = line.
                                        end.
                                        /* ALEZHU RASHIFROVKA LINIJ JLPZ */
                                        f = "".
                                        def var answ as log init yes.
                      if glkon > 805000 and glkon < 808000 then do:
                        message "Ievad╗t tranzakcijas at╫ifrejumu?"
                          view-as alert-box buttons yes-no update answ.
                      end.
                                        if answ = Yes then
                                            run mbo_r2.p(17, 3, 
                                            transaction_headerx, line, 
                                                input-output f,
                                                " Tranz√kcijas L╗niju redi╕e╫ana ").
                                     end.
                                    
                                 END.
 
                                dop1 = 0.
                                m = 0.
                                m1 = 0.
                                key = 2.
                                sost2  = 0.
                            end.
                            else do :
                                up with frame cc3.
                            end.
                        end.
                    end.
                end.
            end.
            k = 0.
            if i = 0 then do :
                up with frame cc3.
            end.
        end.
        
        if j = 2 then do :
            s-transaction_header = transaction_headerx.
            run vw_transaction_header.r.
            k = 0.
        end.
        if j = 3 then do :
            s-transaction_header = transaction_headerx.
            run x-jlvou.r.
            k = 0.
        end.
        if j = 4 then do :
            m2 = 0.
            i1 = 0.
            repeat while i1 = 0 :
                message "1 --> Удаление строки   2 --> Удаление всей транзакции"
                update m2.
                if m2 = 1 then do :
                
                    if transaction_header.party begins "AMORT" then do:
                        message "Транзакцию амортизации нужно удалять целиком!".
                        pause 5.
                        hide message no-pause.
                        leave.
                    end.    
                    /* else if transaction_header.party = "PENSIJAS" then do:
                        message "Транзакцию доходов по пенсионным планам " +   
                        "нужно удалять целиком!".
                        pause 5.
                        hide message no-pause.
                        leave.
                    end. */
                    else if transaction_header.party = "NAKAMIZD" or transaction_header.party = "APMAKMOD"
                    then do:
                        message "Транзакцию модуля " + transaction_header.party +
                        " нужно удалять целиком!".
                        pause 5.
                        hide message no-pause.
                        leave.
                    end.
                    else if transaction_header.party = "NORGRIZD" then do:
                        message "Транзакцию по расходам расчетных групп " +   
                        "нужно удалять целиком!".
                        pause 5.
                        hide message no-pause.
                        leave.
                    end.
                    else if can-find(first bjl where bjl.transaction_header = transaction_header.transaction_header and bjl.ref1 matches
                        "*mak_jlmn_CAN_BATCH_WITH_TWO*") then do:
                        message "Нельзя удалить линию. Необходимо полностью удалить транзакцию!".
                        pause 3.
                        hide message no-pause.
                        leave.
                    end.
                    s-transaction_header = transaction_headerx.
                    run d_xjl1.r.
                    clear frame cc3 no-pause.
                    up 6 with frame cc3.
                    hide all no-pause.
                    run vw_transaction_header.r.
                    up 6 with frame cc3.
                    clear all no-pause.
                    k = 0.
                    i1 = 1.
                    clear all no-pause.
                end.
                if m2 = 2 then do :
                    s-transaction_header = transaction_headerx.
                    run d_xtransaction_headerx.r(output sost3).
                    if sost3 = 1 then do :
                        k = 1.
                        i1 = 1.
                        i2 = 1.
                    end.
                    else do :
                        i1 = 0.
                    end.
                end.
            end.
            if m2 = 0 then k = 0.
        end.
        if j = 5 then do :
            s-transaction_header = transaction_headerx.
            run jl_st1x.r.
            k = 0.
        end.
    end.
    if k <> 1  then do :
        deb = 0.0.
        kre = 0.0.
        keyres = no.
        keynores = no.
        /*
        keyoth = no.
        */
        do k2 = 1 to 50 :
            debx[k2] = 0.0.
            krex[k2] = 0.0.
        end.
        find transaction_header where transaction_header.transaction_header = s-transaction_header no-error.
        for each jl of transaction_header no-lock :
            find gl of jl no-lock no-error.
            if gl.totgl <> 300000 and gl.totgl <> 600000 then do :
                debx[jl.crc] = debx[jl.crc] + jl.dam.
                krex[jl.crc] = krex[jl.crc] + jl.cam.
                deb = deb + jl.dam.
                kre = kre + jl.cam.
            end.
            if gl.subled = "CIF" then do :
                find aaa where aaa.aaa = jl.acc no-lock no-error.
                if available aaa then do :
                    find cif where cif.cif = aaa.cif no-lock no-error.
                    if available cif then do :
                        if cif.prefix = "LV" then keyres = yes.
                        else do :
                            keynores = yes.
                            prefix = cif.prefix.
                        end.
                    end.
                end.
            end.
            if gl.subled = "LON" and gl.gl < 700000 then do :
                find lon where lon.lon = jl.acc no-lock no-error.
                if available lon then do :
                    find cif where cif.cif = lon.cif no-lock no-error.
                    if available cif then do :
                        if cif.prefix = "LV" then keyres = yes.
                        else do:
                            keynores = yes.
                            prefix = cif.prefix.
                        end.
                    end.
                end.
            end.
            /*
            if gl.gl < 500000 and transaction_header.party eq "" and transaction_header.cif eq ""
            and gl.subled ne "CIF" and gl.subled ne "LON" then do :
                keyoth = yes.
            end.
            */
        end.
        atl = deb - kre.
        ubkey = no.
        do k2 = 1 to 50 :
            if debx[k2] ne krex[k2] then ubkey = yes.
        end.
        if (atl <> 0.0 or ubkey = yes)
        and (g-ofc = "root" or g-ofc = "adm" or g-ofc = transaction_header.who) then do :
            message "Созданная транзакция является несбалансированной !!!".
            pause 3.
            repeat while i3 = 0 on endkey undo,leave :
                message "Оставить так ?" update ques2.
                if ques2 = no then do:
                    i2 = 0.
                    i3 = 1.
                    k = 0.
                end.
                else do :
                    output to /bank/pm/data/u_tr.txt append.
                    put g-today at 2 string(time,"hh:mm:ss") at 15 g-ofc at 27
                    s-transaction_header format "zzzzzzzzz9" at 40 skip.
                    output close.
                    i2 = 1.
                    i3 = 1.
                end.
            end.
            if i3 = 0 then do :
                i2 = 0.
                k = 0.
            end.
            i3 = 0.
        end.
        else i2 = 1.
        if keyres = yes and keynores = yes and transaction_header.jdt = g-today 
        and (transaction_header.who = g-ofc or g-ofc = "adm" or g-ofc = "root") then do :
            update 
            prefix validate(can-find(cntry where cntry.st = prefix
            and cntry.sts ne 9)
            and prefix ne "", "Не верно указан код страны !") 
            help "Введите код страны Нерезидента (F2 - помощь)"
            with frame cc5.
            find cntry where cntry.st = prefix no-lock no-error.
            cndes = cntry.des.
            display cndes with frame cc5.
            update pcod validate(can-find(pcod where pcod.pcod = pcod) or 
            pcod = 0,"Не существующий \"┘rёjo maks√juma kods\"")
            help "Введите \"┘rёjo maks√juma kods\" (F2 - помощь)" 
            with frame cc5.
            do transaction:
                find transaction_header where transaction_header.transaction_header = transaction_headerx.
                transaction_header.tty = pcod.
                transaction_header.del = prefix.
                i2 = 1.
            end.
        end.
        /*
        else
        i2 = 1.
        */
    end.
end.
hide all no-pause.
procedure cda_chkc :    
        if baa3.pass = "U" then do :
            strx = substr(string(baa3.lstmgbal,"999999999999999999999"),14,8). 
            if strx ne "00000000" then do :
                mdat = date(int(substr(strx,5,2)),int(substr(strx,7,2)),
                int64(substr(strx,1,4))).
                if mdat < g-today then do :
                    message 
           "Превышен максимальный срок пополнения универсального депозита !".
                    pause 3.
                    hide message no-pause.
                end.
                else do:
                  dbt = 0.0.
                  prizn = "C".
                  display dbt with frame cc3.
                  m1 = 1.
                end.
            end.
            else do :
                dbt = 0.0.
                prizn = "C".
                display dbt with frame cc3.
                m1 = 1.
            end.
        end.    
        else if (baa3.regdt > 05/14/2000 and baa3.pass = "T") 
            or baa3.pass = "K" then do :
            find dpdeal where dpdeal.dpdeal = baa3.aaa no-lock no-error.
            if not available dpdeal or dpdeal.tim = 0 then do :
            
                if dpdeal.tim = 0 then do :
                  run idepo_lgr.p(baa3.aaa,output idepoind).
                  if idepoind ne 0 then do:
                    message "Не возможно пополнять IDEPO депозит !".
                    pause 3.
                    hide message no-pause.
                  end.
                end.
      
                if baa3.pass = "K" or baa3.pass = "T" then dx2 = baa3.regdt.
                else do :
                    run nx_dt(baa3.regdt,output dx1).
                    run nx_dt(dx1,output dx2).
                end.
                find first dpgrp where
                  dpgrp.dpgrp eq dpdeal.grp and
                ( dpgrp.dpgrp eq 21 or
                  dpgrp.dpgrp eq 22 ) no-lock no-error.
                if not available dpgrp and
                  (( baa3.expdt - baa3.regdt < 32 and
                       g-today > baa3.regdt ) or
                   ( baa3.expdt - baa3.regdt > 31 and
                       g-today > dx2 )) then do :
                    message  
                    "Превышен максимальный срок внесения депозита !".  
                    pause 3.
                    hide message no-pause.
                end. 
                else if g-today ge baa3.expdt then do :
                    message 
                    "Превышен максимальный срок внесения депозита !".
                    pause 3.
                    hide message no-pause.
                end.
                else 
                if ost7x + krd > baa3.opnamt then do :
                    message "Превышена сумма по депозитному договору !".
                    pause 3.
                    hide message no-pause.
                end.
                else do :
                    find first dpdeal where dpdeal.dpdeal = baa3.aaa no-error.
                    if available dpdeal and dpdeal.grp ne 1 then do :
                        if dpdeal.sts < 5 then do :
                            dpdeal.sts = 5.
                            dpdeal.vtransaction_header = transaction_headerx.
                        end.    
                    end.    
                    dbt = 0.0.
                    prizn = "C".
                    display dbt with frame cc3.
                    m1 = 1.
                end.
            end.    
            else do :
                find first dpdeal where dpdeal.dpdeal = baa3.aaa no-error.
                if available dpdeal and dpdeal.grp ne 1 then do :
                    if dpdeal.sts < 5 then do :
                        dpdeal.sts = 5.
                        dpdeal.vtransaction_header = transaction_headerx.
                    end.    
                end.    
                dbt = 0.0.
                prizn = "C".
                display dbt with frame cc3.
                m1 = 1.
            end.
        end.
        /*
        else if baa3.regdt le 05/14/2000 and baa3.pass = "T" then do :
            message 
            "Превышен максимальный срок внесения срочного депозита !".
            pause 3.
            hide message no-pause.
        end.
        */
        else do :
            dbt = 0.0.
            prizn = "C".
            display dbt with frame cc3.
            m1 = 1.
        end.
end procedure.
*/
/*
DELETE_OBJECTS_MLAAD().
*/