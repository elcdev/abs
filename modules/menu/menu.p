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

DEFINE VARIABLE menuForm AS menuForm.

menuForm = NEW menuForm().

FUNCTION deleteObjects CHARACTER():
    DELETE OBJECT menuForm NO-ERROR.
END.

/* 20 + 30 + 30 */
menuForm:showMenu().

deleteObjects().

QUIT.