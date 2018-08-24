/* sysbra */
{mainhead.i SSBRANCH}

def var s-bra like bra.bra.
def var vans as log.
def var vsele as cha form "x(12)" extent 4
 initial ["Next", "Edit", "Delete", "Quit"].
form vsele with frame vsele col 67 1 col row 3 overlay no-label.
form  bra.bra bra.name bra.addr[1] bra.addr[2]
                  bra.addr[3] format 'x(3)' label 'KODS'  
                  bra.ref format 'x(11)' label 'RE².NR.'
                  bra.tel bra.contact bra.regdt 
                  bra.tim format '9' label 'STS'
                  bra.auxint format '>>9' label 'FILI…LES'
                  bra.ref1 format 'x(2)' label 'FILI…LES KODS' with frame bra 1 col.
DEF VAR cBraInfo AS sysBraInfo.
cBraInfo = NEW sysBraInfo().
bra.name:format in frame bra = "x(120)".
bra.name:width in frame bra = 30.
bra.addr[1]:format in frame bra = "x(120)".
bra.addr[1]:width in frame bra = 30.
bra.addr[2]:format in frame bra = "x(120)".
bra.addr[2]:width in frame bra = 30.
bra.tel:format in frame bra = "x(300)".
bra.tel:width in frame bra = 30.
procedure upd_fields:
    display bra.bra with frame bra.
    main_upd:
    DO ON error undo:
         update  bra.name bra.addr[1] bra.addr[2]
                  bra.addr[3] format 'x(3)' label 'KODS'  
                  bra.ref format 'x(11)' label 'RE².NR.'
                  bra.tel bra.contact 
                  bra.tim format '9' label 'STS' 
                  help '0 - ÏÂÙÞÎÙÊ 2 - ÐÒÁ×Á ÎÁ ÆÉÌÉÁÌ 9 - ÓÐÅÃÉÁÌØÎÙÊ'
                  bra.auxint format '>>9' label 'FILI…LE'
                  help 'Nor.grupai attiecigas fili–les numurs'
                  bra.ref1 format 'x(2)' label 'FILI…LES KODS'
                  help 'Nor.grupai attiecigas fili–les kods' with frame bra.
         bra.who = userid('bank').
         bra.whn = g-today.
         bra.UpdateCount = next-value(UpdateCount, bank).
         if bra.id = 0 then bra.id = bra.bra. /*next-value(bra_id, bank).*/
         
         find company where company.logo eq bra.addr[3] no-error.
         IF AVAILABLE company THEN company.code = caps(bra.ref1).
         
    end.
end.
function createNewBra int64(tBra AS INT64):
    IF tBra = 0 THEN
        s-bra = cBraInfo:getNextBra().
    ELSE
        s-bra = tBra.
        
    create bra.
    bra.bra         = s-bra.
    bra.id          = bra.bra. 
    bra.UpdateCount = next-value(UpdateCount, bank).
    bra.who         = userid('bank').
    bra.whn         = g-today.
    
    return s-bra.
end.
outer:
repeat:
  clear frame bra.
  {mesg.i 9819}.
  prompt bra.bra with frame bra.
  if input bra.bra = 0 then
     do transaction:
         {mesg.i 0404}.
         createNewBra(0).
         display bra.bra with frame bra.
         
         run upd_fields.         
         if bra.name = "" then undo outer.
     end.
  else do :
      find bra using bra.bra no-error.
      if not available bra then do transaction:
        {mesg.i 0802}.
        createNewBra(input bra.bra).
        run upd_fields.
        if bra.name = "" then undo outer.
      end.
  end.
  s-bra = bra.bra.
  
  inner:
  repeat:
          clear frame bra.
          
          display  bra.bra bra.name bra.addr[1] bra.addr[2]
                  bra.addr[3] format 'x(3)' label 'KODS'  
                  bra.ref format 'x(11)' label 'RE².NR.'
                  bra.tel bra.contact bra.regdt
                  bra.tim format '9' label 'STS'
                  bra.auxint format '>>9' label 'FILI…LE'
                  bra.ref1 format 'x(2)' label 'FILI…LES KODS' with frame bra.
          pause 0.
    display vsele with frame vsele.
    put cursor row frame-row(vsele) column frame-col(vsele).
    choose field vsele auto-return with frame vsele.
    hide frame vsele.
    if frame-value = "Edit"
    then 
     do:
          view frame bra.
          run upd_fields.
          if bra.name = "" then undo outer.
     end.
    else if frame-value = "Quit" then 
     do:
        leave outer.
     end.
    else if frame-value = "Delete" then 
     do:
        vans = no.
        {mesg.i 0824} update vans.
        if vans then 
         do:
            {mesg.i 0805}.
            delete bra.
            leave.
         end.
        else 
            {mesg.i 0212}.
     end.
    else if frame-value = "Next" then leave.
    else if frame-value = " " then 
     do:
        {mesg.i 9205}.
        pause 2.
     end.
  end.
  
end.
DELETE OBJECT cBraInfo NO-ERROR.
 
