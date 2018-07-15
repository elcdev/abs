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
      Settings:g-today FORMAT "99.99.9999"
  " " Settings:companyName FORMAT "X(29)"
  " " Settings:loginName FORMAT "X(20)"
  .
  


deleteObjects().