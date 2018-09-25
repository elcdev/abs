USING system.ui.*.
USING modules.menu.*.
USING system.api.menu.*.
USING system.api.systemSettings.*.

CLASS modules.menu.menuEditForm INHERITS baseForm:
    {menuEditTable.i }
    
    DEFINE VARIABLE cMenuApi    AS menuApi NO-UNDO.
    DEFINE VARIABLE parentId    AS INT64     NO-UNDO INITIAL 0.
    {propertyGetSet.f &name="dataChanged"   &type="LOG"}
    
    DEFINE QUERY formQuery FOR formEditTable.
    
    DEFINE BROWSE formBrowse QUERY formQuery DISPLAY
        formEditTable.fieldName    FORMAT "X(20)" LABEL "Field Name"
        formEditTable.fieldValue   FORMAT "X(20)" LABEL "Value"
        WITH 15 DOWN NO-BOX NO-LABELS NO-SCROLLBAR-VERTICAL
        SIZE 43 BY 13
        .
        
    DEFINE FRAME formFrame
        formBrowse HELP " " SKIP
      WITH NO-LABELS SIZE 45 BY 15 OVERLAY ROW 4
      CENTERED.

    {formBrowserBaseMethods.f &formTable="formEditTable"}
    
    CONSTRUCTOR menuEditForm():
        cMenuApi = NEW menuApi().
    END.
    
    CONSTRUCTOR menuEditForm(iParentId AS INT64):
        cMenuApi = NEW menuApi().
        parentId = iParentId.
    END.
    
    DESTRUCTOR menuEditForm():
        DELETE OBJECT cMenuApi NO-ERROR.
    END.
    
    METHOD PUBLIC CHARACTER InitForm():
        RETURN "".
    END.
    
    METHOD PUBLIC VOID ShowData():
        ENABLE formBrowse WITH FRAME formFrame. 
        PAUSE 0.
    END.

    METHOD PUBLIC RECID SearchByKeyword():
        IF searchKeyWord = "" OR searchKeyWord = ? THEN RETURN SearchById(tmpFormId).

        FIND FIRST formEditTable WHERE formEditTable.fieldName MATCHES '*' + searchKeyWord + '*' NO-ERROR.
        IF AVAILABLE formEditTable THEN RETURN RECID(formEditTable).

        FIND FIRST formEditTable WHERE formEditTable.fieldValue MATCHES "*" + searchKeyWord + "*" NO-ERROR.
        IF AVAILABLE formEditTable THEN RETURN RECID(formEditTable).
        
        searchKeyWord = SUBSTRING(searchKeyWord, 1, LENGTH(searchKeyWord) - 1).
        
        RETURN SearchByKeyword().
    END.

    METHOD PUBLIC CHARACTER recordset(iId AS INT64):
        tmpFormId = iId.
        recordset().
    END.
    
    METHOD PUBLIC CHARACTER recordset():
        EMPTY TEMP-TABLE formEditTable.
        cMenuApi:getItemData(tmpFormId, INPUT-OUTPUT TABLE formEditTable BY-REFERENCE).
        openQuery().
        RETURN "".
    END.
    
    ON RETURN OF formBrowse
     DO:
        IF NOT AVAILABLE formEditTable THEN RETURN.
        
        DEFINE VARIABLE editorStatus AS CHAR.
        DEFINE VARIABLE fieldEditor  AS fieldEditForm.

        fieldEditor = NEW fieldEditForm().
        fieldEditor:TOP   = formEditTable.fieldValue:ROW   IN BROWSE formBrowse + FRAME formFrame:ROW.
        fieldEditor:Left  = formEditTable.fieldValue:COL   IN BROWSE formBrowse + FRAME formFrame:COL.
        fieldEditor:WIDTH = formEditTable.fieldValue:Width IN BROWSE formBrowse.
        fieldEditor:VALUE = formEditTable.fieldValue.
            
        DisableForm().
        fieldEditor:ShowForm().
        
        IF fieldEditor:State = "" THEN 
         DO:
            formEditTable.fieldValue = fieldEditor:VALUE.
            formBrowse:refresh().
            dataChanged = TRUE.
         END.
         
        DELETE OBJECT fieldEditor NO-ERROR.
        
        ShowData().
        RETURN "".
     END.
    
	METHOD PRIVATE CHARACTER saveData():
        RETURN cMenuApi:setValuesFromEditBuffer(tmpFormId, INPUT-OUTPUT TABLE formEditTable).
    END.
    
	ON PF4, F4 OF formBrowse
	 DO:
        DEFINE VARIABLE answer AS LOG NO-UNDO.
        IF dataChanged THEN
         DO:
            MESSAGE "Save data" VIEW-AS ALERT-BOX BUTTONS YES-NO UPDATE answer.
            IF answer THEN saveData().
         END.
		
        DisableForm().
		HideForm().
	 END.
  
END.
