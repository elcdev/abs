/*
 MAIN MENU
*/
{euro_ready.i} /* by alechi */
def input parameter fath as character format "x(8)".
def input parameter pos as int64.
def output parameter er as int64 initial 0.
def buffer b1nmenu for nmenu.
def buffer b2nmenu for nmenu.
def buffer bnm     for nmenu.
def var S as char format "x(1)".
def var counter as int64.
def var i  as int64 no-undo.
def var jj as int64 no-undo.
def var lin  as int64 format ">9".
def var dsc like nmdes.des format "x(45)".
def var func like nmenu.fname.
def var k as int64.
def var tim as character.
def var titul as character format "x(80)".
def var System_Ver as char no-undo format "x(46)".
def var KeyInt     as int  no-undo format ">>>9".
def var KeyStr     as char no-undo format "x(1)".
{global.i}
form
    g-comp format "x(22)" no-label at 1
    System_Ver no-label at 25
    tim no-label
    at 73 with frame tt row 1 column 1 color input no-box.
form
    titul at 1 no-label with frame tit color
    message row 2 column 1 no-box.
form
     lin column-label "MENU!NUMURS" at 5
     dsc column-label "MENU NOSAUKUMS" at 12
     func column-label "FUNKCIJAS!NOSAUKUMS" at 60
     S at 70
     "     " at 74
     with frame cust-frame SCROLL 1 13 DOWN  ROW 3 column 1 
     .
if fath = "MENU" then g-mdes = "MENU".
else do :
    find bnm where bnm.fname = fath no-lock no-error.
    find nmdes of bnm where nmdes.lang = g-lang no-lock no-error.
    if available nmdes then g-mdes = nmdes.des. else g-mdes = "".
end.
System_Ver = "ABS \"NORVIK\" VER.14.2.".
if not g-WriteMode then System_Ver = System_Ver + " (READ ONLY)".
find last cls no-lock no-error.
if cls.cls + 1 lt 01/05/2014 and g-mdes eq "MENU" then
titul = "                          HAPPY NEW YEAR !!!".
else
titul = fath + fill(" ",8 - length(fath)) +
    substring(g-mdes,1,52) + fill(" ",52 - length(g-mdes)) +
    caps(g-ofc) + fill(" ",8 - length(g-ofc)) + "  " +  
    string(g-today,"99/99/9999").
tim = string(time,"hh:mm:ss").
display g-comp System_Ver tim with frame tt.
display titul help "" with frame tit.
hide frame cust-frame no-pause.
run set_title.p (fath,"",g-mdes).
REPEAT COUNTER = 1 TO 13:
    find NEXT nmenu where nmenu.father = fath no-lock no-error.
    if available nmenu then do :
        find nmdes of nmenu where nmdes.lang = g-lang no-lock no-error.
        if available nmdes then dsc = nmdes.des. else dsc = "".
        if nmenu.ntty eq 9999 then S = "S". else S = "".
        if nmenu.proc eq "" then S = ">".
        if nmenu.link ne "" then S = "^".
        if g-ofc eq "alechi" then do:
          
          if nmenu.ntty eq 9999 then do:
            assign KeyInt = nmenu.ntty
                   KeyStr = "STDR (������� � �������������� �������!)".
          end.
          else do:
            assign KeyInt = 0
                   KeyStr = "".
          end.
          if KeyStr eq "" and nmenu.proc ne "" then do:
            if search(nmenu.proc + ".r") eq ? then do:
              assign KeyInt = 1
                     KeyStr = "PROGRAM (����������� ���������!)".
            end.
          end.
          else if KeyStr eq "" and nmenu.link eq "" then do:
            find first b1nmenu where b1nmenu.father eq nmenu.fname
                                      no-lock no-error.
            if not available b1nmenu then do:
              assign KeyInt = 2
                     KeyStr = "MENU (����������� �������!)".
            end.
          end.
          
          if KeyInt ne 0 then do:
            assign S = substr(KeyStr, 1, 1).
            if S ne "S" then S = "-".
          end.
          
        end.
        lin = nmenu.ln.
        func = nmenu.fname.
        display lin dsc func S with frame cust-frame.
        DOWN WITH FRAME cust-frame.
        k = k + 1.
    end.
end.
if k gt 0 then do:
    if pos ne 1 and g-ofc eq "alechi" then do:
      jj = 0.
      for each b2nmenu where b2nmenu.father eq fath no-lock:
        jj = jj + 1.
        if b2nmenu.ln eq pos then leave.
      end.
      if jj gt 1 and jj ne pos then pos = jj.
    end.
    
    up (k + 1 - pos) with frame cust-frame.
    
    choose row lin color messages no-error pause 120 with frame cust-frame.
    /*
    color DISPLAY normal lin dsc func S
    WITH FRAME cust-frame .
    */
end.
else er = 1.
