/*
********************************************************************************
********************************************************************************
12.07.2018 22:48   ABS SYSTEM                                       Alan Meister
--------------------------------------------------------------------------------
POS FUNCTION DESCRIPTION                                                 SUBMENU
================================================================================
1   CLIENTS  Clients main menu                                                 >
================================================================================
Find menu         [************************************************************]
*/

DEFINE VARIABLE Settings AS globalSettings.

Settings = NEW globalSettings().

FUNCTION deleteObjects CHARACTER():
    DELETE OBJECT Settings NO-ERROR.
END.

/* 20 + 30 + 30 */
DEFINE FRAME headerFrame
      STRING(Settings:g-today, "dd.mm.yyyy")
  " " STRING(TIME, "hh:mm:ss")
  " " STRING(Settings:companyName, "X(29)")
  " " STRING(Settings:companyName, "X(30)").

FUNCTION showHeaderFrame VOID():
	VIEW FRAME headFrame. PAUSE 0.
END.

{menuTable.i}

DEFINE BROWSE bf 
	tmpMenu.

DEFINE FRAME dataFrame
	bf HELP ""
	.

FUNCTION dataRecordset VOID():

END.

deleteObjects().