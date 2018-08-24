/* global.i */
&IF DEFINED(global_i)
  &THEN
  
  &ELSE
define {1} shared var g-lang   like bank.lang.lang.
define {1} shared var g-crc    AS INT64 FORMAT ">>9".
define {1} shared var g-ofc    AS CHAR.
define {1} shared var g-proc   like bank.nmenu.proc.
define {1} shared var g-fname  like bank.nmenu.fname.
define {1} shared var g-mdes   like bank.nmdes.des.
define {1} shared var g-today  as date.
define {1} shared var g-comp   like bank.cmp.name.
define {1} shared var g-dbdir  as cha. /* Database Directory */
define {1} shared var g-dbname as cha. /* Database Name */
define {1} shared var g-bra    like bank.bra.bra.
{2}
define {1} shared variable g-basedy AS INT64.
define {1} shared variable g-aaa    AS CHAR FORMAT "X(10)".
define {1} shared variable g-cif    AS CHAR FORMAT "X(6)".
define {1} shared var g-BaseCrc   as int64 format ">>9"  init 11.
define {1} shared var g-BaseCcy   as char  format "x(3)" init "EUR".
define {1} shared var g-WriteMode as log   format "WriteMode/ReadOnlyMode"
                                                      init yes.
&ENDIF
  
&GLOBAL-DEFINE global_i
