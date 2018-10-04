USING system.api.systemSettings.*.
USING system.api.core.*.
USING system.ui.*.
USING modules.menu.*.


CLASS modules.menu.headerForm INHERITS baseForm:

DEFINE VARIABLE g-today       AS DATE NO-UNDO.
DEFINE VARIABLE companyName   AS CHARACTER NO-UNDO.
DEFINE VARIABLE loginName     AS CHARACTER NO-UNDO.
  
/* 20 + 30 + 30 */
DEFINE FRAME headerFrame
      g-today     FORMAT "99.99.9999"
      companyName FORMAT "X(29)":L
      loginName   FORMAT "X(10)" AT 65
  
  WITH NO-LABELS NO-BOX SIZE 80 BY 1 ROW 1 CENTERED.
  
CONSTRUCTOR headerForm():
    g-today     = globalSettings:g-today.
    companyName = globalSettings:companyName.
    loginName   = SUBSTRING(globalSettings:loginName, 1, 10).
    loginName   = STRING(FILL(" ",10 - LENGTH (loginName)) + loginName, "X(10)").
    FRAME headerFrame:SCROLLABLE = FALSE.
END.

DESTRUCTOR headerForm():
    
END.

METHOD PUBLIC OVERRIDE CHARACTER showHeader():
    VIEW FRAME headerFrame. 
    PAUSE 0.
    DISPLAY g-today companyName loginName WITH FRAME headerFrame.
    PAUSE 0.
END.

METHOD PUBLIC OVERRIDE CHARACTER hideHeader():
    HIDE FRAME headerFrame. 
    PAUSE 0.
END.

METHOD PUBLIC CHARACTER getSeparator():
    RETURN FILL("=", 80).
END.

END.