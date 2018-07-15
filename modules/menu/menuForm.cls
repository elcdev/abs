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
CLASS menuForm INHERITS headerForm:

{menuTable.i}

DEFINE QUERY menuQuery FOR menuTable.

DEFINE BROWSE menuBrowse QUERY menuQuery
    position    FORMAT ">9"    LABEL "LN"
    description FORMAT "X(30)" LABEL "DESCRIPTION"
    WITH 18 DOWN NO-BOX NO-LABELS
    .
    
DEFINE FRAME menuFrame
    menuBrowse HELP " "
  WITH NO-LABELS NO-BOX.
  
CONSTRUCTOR headerForm():

END.

DESTRUCTOR headerForm():

END.


METHOD PUBLIC CHARACTER showMenu():
    SUPER:showHeader().
    VIEW FRAME headerFrame. PAUSE 0.
END.

END.