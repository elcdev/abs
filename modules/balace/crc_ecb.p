/*
 ECB RATES
 by alechi, alezhu
 crc_ecb.p
*/
{euro_ready.i} /* by alechi */
DEF VAR cstr        AS sysstr   NO-UNDO.
DEF VAR cbnk        AS sysbnk   NO-UNDO.
def var ques as log.
def var que2 as log.
cstr = NEW sysstr().
cbnk = NEW sysbnk().
DEF TEMP-TABLE Cube NO-UNDO
    FIELD DT       AS DATE FORMAT "99/99/9999"
    FIELD CURRENCY AS CHAR
    FIELD RATE     AS DEC FORMAT ">>>>>9.99999999"
    FIELD CRC      AS INT64
    .
def buffer bcube for cube.
def var ii as int.
{prg_head.f}
/*
 find sysc where sysc.sysc eq "PARDAT" no-lock no-error.
 if available sysc and sysc.daval ge g-today then do:
   message "Can not change CB rate, revaluation already has been!".
   pause 5.
   hide message no-pause.
   return.
 end.
*/
FUNCTION Add_Cube INT(f_Dt AS DATE, f_CURRENCY AS CHAR, f_RATE AS CHAR):
    IF f_CURRENCY = ? OR TRIM(f_CURRENCY) = "" THEN RETURN -1.
    CREATE Cube.
    Cube.Dt       = f_Dt.
    Cube.CURRENCY = TRIM(f_CURRENCY).
    Cube.RATE     = DEC(f_RATE) NO-ERROR.
    Cube.CRC      = cbnk:Get_Crc_By_Code(Cube.CURRENCY).
END.
FUNCTION ParseXml INT (hNode as HANDLE, f_Dt AS DATE):
  DEF VAR ii        AS INT64  no-undo.
  DEF VAR hNodeTemp AS HANDLE no-undo.
  DEF VAR hNodeNxt1 AS HANDLE no-undo.
  DEF VAR f_Dts     AS CHAR   NO-UNDO.
  CREATE X-NODEREF hNodeTemp.
  REPEAT ii = 1 TO hNode:num-children:
    IF hNode:get-child(hNodeTemp,ii) THEN 
     DO:
        f_Dts = hNodeTemp:GET-ATTRIBUTE("time").
        IF f_Dts <> ? AND f_Dts <> "" THEN
            f_Dt = cstr:Get_Date_By_Str(f_Dts, "yyyy-mm-dd").
        Add_Cube(f_Dt, hNodeTemp:GET-ATTRIBUTE("currency"),
            hNodeTemp:GET-ATTRIBUTE("rate")).
        if hNodeTemp:num-children > 0 then ParseXml(hNodeTemp, f_Dt).
     END.
  END.
  DELETE OBJECT hNodeTemp NO-ERROR.
END.
FUNCTION LoadRates INT(fName AS CHAR):
    DEF VAR Xml         AS HANDLE   NO-UNDO.
    DEF VAR XmlBuffer   AS MEMPTR   NO-UNDO.
    COPY-LOB FILE fName TO XmlBuffer.
    CREATE X-DOCUMENT Xml.
    Xml:LOAD("MEMPTR", XmlBuffer, false).
    ParseXml(Xml, ?).
    SET-SIZE(XmlBuffer) = 0.
    DELETE OBJECT Xml  NO-ERROR.
END.
FUNCTION Wget CHAR():
    unix silent /*** http_proxy=http://proxy.ltk:8080 ****/ wget "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml" -o eurofxref-daily.log.
    RETURN "eurofxref-daily.xml".
END.
Wget().
LoadRates("eurofxref-daily.xml").
DELETE OBJECT cstr NO-ERROR.
DELETE OBJECT cbnk NO-ERROR.
que2 = no.
find first bcube where bcube.rate ne 0.0 no-error.
if available bcube then do:
  if bcube.dt ne g-today then do:
    message "Дата курса -" bcube.dt ", текущая дата -" g-today.
    message "Отличаются дата курса и текущая дата. Продолжить?" update ques.
    if not ques then return.
    que2 = yes.
  end.
  
  find first sysc where sysc.sysc eq "EUROSTART" no-lock no-error.
  
  if sysc.daval eq g-today then do transaction:
    find crc where crc.crc eq 11 no-error.
    if crc.rate[1] eq 0.0 then do:
      do ii = 1 to 9:
        if ii eq 8 then crc.rate[ii] = 0.0. else crc.rate[ii] = 1.0.
      end.
      
      find first crchis where crchis.crc eq crc.crc and
                              crchis.rdt eq g-today no-error.
      if not available crchis then do:
        create crchis.
        assign crchis.crc = crc.crc
               crchis.rdt = g-today.
      end.
      buffer-copy crc except id updatecount to crchis.
    end.
  end.
  
  output to err.txt.
  for each Cube where cube.crc gt 0.0 by cube.crc by cube.currency:
      find crc where crc.crc eq cube.crc no-error.
      if available crc and crc.crc ne 1 then do:
        assign crc.regdt = g-today.
        
        if sysc.daval le g-today then do:
          assign crc.rate[1] = 1
                 crc.rate[9] = round(cube.rate, 6).
        end.
        find first crchis where crchis.crc eq crc.crc and
                                crchis.rdt eq g-today no-error.
        if not available crchis then do:
          create crchis.
          assign crchis.crc = crc.crc
                 crchis.rdt = g-today.
        end.
        buffer-copy crc except id updatecount to crchis.
        assign crchis.tim     = time
               crchis.who     = g-ofc
               crchis.whn     = today.
      end.
  end.
  output close.
  
  /* MP0114/09 by alechi 24.01.2014 -> */
  find sysc where sysc.sysc eq "PARDAT" no-lock no-error.
  if true /* not sysc.loval */ then do transaction:
    find sysc where sysc.sysc eq "PARDAT" no-error.
    assign sysc.loval = yes.
    if que2 then sysc.sts = 1. else sysc.sts = 0.
    release sysc.
  end.
  /* MP0114/09 by alechi 24.01.2014 <- */
  
  unix silent rm -f eurofxref-daily.log*.
  unix silent rm -f eurofxref-daily.xml*.
  
  hide message no-pause.
  output to err.txt append.
  put unformatted "RATES DATE IS "
                  string(bcube.dt, "99/99/9999")
                  "." skip
                  "BANKING DAY IS "
                  string(g-today, "99/99/9999")
                  "." skip
                  "NOW IS "
                  string(today, "99/99/9999") " "
                  string(time, "HH:MM:SS") "." skip.
  output close.
  message "Transfer complete successfully. ECB rates date is"
          string(bcube.dt,"99/99/9999") "!".
  pause 5.
end.
/*****
/* ALEZHU: 24.10.2014 Obnovlenije kursov na saite */
DEF VAR cWebSiteData as WebSiteData NO-UNDO.
cWebSiteData = NEW WebSiteData().
cWebSiteData:Update_All("CRCHIS").
DELETE OBJECT cWebSiteData.
*****/
