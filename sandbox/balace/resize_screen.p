def input  parameter h as integer.
def input  parameter w as integer.
def output parameter ok as logical.
def var platon_screen_height as integer.
def var platon_screen_width as integer.
pause 0 before-hide.

return.


ok = no.
platon_screen_height = -1.
platon_screen_width = -1.
/*
run get-screen-size.
*/
run screen_size.p (output platon_screen_height, output platon_screen_width).
if platon_screen_height = -1 or
   platon_screen_width = -1 then leave.
if platon_screen_height = h and
   platon_screen_width = w then do:
  ok = yes.
  leave.
end.
unix silent value(substitute("echo -e ""~\0033[8;&1;&2t""; sleep 1",h,w)).
term = "xterm".
term = "xterm".
term = "xterm".
term = "xterm".
/*
run get-screen-size.
*/

run screen_size.p (output platon_screen_height, output platon_screen_width).
if platon_screen_height < h or
   platon_screen_width < w then leave.
ok = yes.
leave.
/*
procedure get-screen-size:
  def var s as char no-undo.
  def var i as integer no-undo.
  def var flag as char no-undo.
  input through value("stty -a").
    repeat:
      import unformatted s.
      repeat i = 1 to num-entries(s," "):
        /* log-manager:write-message(entry(i,s," "),"STTY"). */
        if entry(i,s," ") = "rows" then do:
          platon_screen_height = -1.
          platon_screen_height = integer(replace(entry(i + 1,s," "),";","")) no-error.
          if platon_screen_height = -1 then do:
            platon_screen_height = integer(replace(entry(i + 2,s," "),";","")) no-error.
          end.
          if platon_screen_height = -1 then do:
            log-manager:write-message("Cannot get ROWS attribute","STTY").
            return.
          end.
        end.
        else if entry(i,s," ") = "columns" then do:
          platon_screen_width = -1.
          platon_screen_width = integer(replace(entry(i + 1,s," "),";","")) no-error.
          if platon_screen_width = -1 then do:
            platon_screen_width = integer(replace(entry(i + 2,s," "),";","")) no-error.
          end.
          if platon_screen_width = -1 then do:
            log-manager:write-message("Cannot get COLUMNS attribute","STTY").
            return.
          end.
        end.
      end.
    end.
  input close.
end procedure.
end procedure.
