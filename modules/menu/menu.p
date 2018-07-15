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

DEFINE VARIABLE headerForm AS headerForm.

headerForm = NEW headerForm().

FUNCTION deleteObjects CHARACTER():
    DELETE OBJECT headerForm NO-ERROR.
END.

/* 20 + 30 + 30 */
headerForm:showHeader().

deleteObjects().