/*
 prg_head.f
  -> prg_hea1.f
     head.f
     mainhead.i
  ! -> chg_usrs.p
       kn_reprt.p
       rmirep.p
       rmorep.p
*/
{global.i}
 
disp                                                                      " " +
     substr(g-mDes,       1, 45) + fill(" ", 48 - length(g-mDes))       + " " +
     substr("BONUS-ELC",     1,  9) + fill(" ",  12 - length("BONUS-ELC"))     + " " +
     substr(caps(g-Ofc),  1,  6) + fill(" ",  9 - length(g-Ofc))        + " " +
       string(g-today,"99/99/9999")
  format "x(80)" with frame tit{1} color message /* centered */ row 2 no-box.
 
