/* Include to program: new_mm.p */
def var ofcsec  as char                 no-undo.
def var fst_obj as Progress.Lang.Object no-undo.
fst_obj = session:last-object.
/* Clear objects and connects */
def temp-table wobj no-undo
field obj as Progress.Lang.Object
index obj obj.
function delete_objects_to_first int64(f_Mode as int64):
    def var cur_obj as Progress.Lang.Object no-undo.
    def var nxt_obj as Progress.Lang.Object no-undo.
    if   fst_obj ne ? 
    then nxt_obj = fst_obj:next-sibling no-error.
    else nxt_obj = session:first-object no-error.
    if nxt_obj eq ? then leave.
    do while valid-object(nxt_obj):
      cur_obj = nxt_obj no-error.
      create wobj no-error.
      assign wobj.obj = cur_obj no-error.
      nxt_obj = nxt_obj:next-sibling no-error.
    end.
    for each wobj:
      if valid-object(wobj.obj) then
       do:
          delete object wobj.obj no-error.
       end.
    end.
    EMPTY TEMP-TABLE wobj NO-ERROR.
 
 
    return 0.
end.
function delete_objects int64():
    return delete_objects_to_first(0).
end.
FUNCTION SET_GLOBALS INT():
    DEF VAR cbnk AS sysbnk NO-UNDO.
    DEF VAR cssc AS sysc   NO-UNDO.
    cbnk = NEW sysbnk().
    cssc = NEW sysc().
    g-today  = cbnk:Get_G_Today().
    g-comp   = cbnk:Get_Company_Name().
    g-basedy = cssc:Get_SysC_Int("BASEDY",365).
    if g-dbname = "" then g-dbname = ldbname(1).
    if g-ofc = ?  then g-ofc = "".
    if g-ofc = "" then g-ofc = caps(os-getenv("LOGNAME")).
    if g-ofc = ?  then g-ofc = "".
    if g-ofc = "" then g-ofc = caps(userid(g-dbname)).
    ofcsec   = g-ofc. /* in new_add.i:set_param */
    g-lang   = OS-GETENV("PLANG").
    g-dbdir  = OS-GETENV("DBDIR").
    g-proc   = "".
    if g-lang eq "" or g-lang eq ? then g-lang = "RS".
    g-bra    = 1.
        
    if lookup("READ-ONLY",DBRESTRICTIONS("bank"),",") eq 0 then do:
      g-WriteMode = yes.
    end.
    else do:
      g-WriteMode = no.
    end.
    
    DELETE OBJECT cbnk NO-ERROR.
    DELETE OBJECT cssc NO-ERROR.
    /* Enable logging for user in sysc = "LOGGER" */
    run logger.p no-error.
    RETURN 0.
END.
procedure set_param:
    SET_GLOBALS().
end.
procedure unaut_log:
  def input param fname as char.
  
  if not g-WriteMode then leave.
  
  create secnot.
  assign secnot.fname = caps(fname)
         secnot.ofc = ofcsec
         secnot.dat = today
         secnot.tim = time.
  release secnot no-error.
end.
FUNCTION MENU_GET_DBLIST CHAR(fName AS CHAR):
    DEF BUFFER nmdes FOR bank.nmdes.
    FIND FIRST nmdes NO-LOCK WHERE nmdes.FNAME = FNAME AND nmdes.LANG = "DB" NO-ERROR.
    IF AVAILABLE nmdes THEN RETURN nmdes.des. 
    RETURN "".
END.
FUNCTION MENU_CONNECT_DBLIST INT(fName AS CHAR, Mode AS INT):
    DEF VAR DBL AS CHAR NO-UNDO.
    DBL = MENU_GET_DBLIST(fName).
    IF DBL <> "" THEN
     DO:
        DEF VAR cdb AS syspdb.
        cdb = new syspdb().
        DEF VAR Rez AS INT NO-UNDO.
        Rez = cdb:ConnectDbList(DBL).
        DELETE OBJECT cdb NO-ERROR.
        IF Rez <> 0 AND Mode = 1 THEN
         DO:
            MESSAGE "Can't connect to all databases: " + DBL "!" VIEW-AS ALERT-BOX.
         END.
     END.
    RETURN Rez. /* 0 - Ok; 1 - Fail */
END.
