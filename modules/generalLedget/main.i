/*
 main.i
*/
define new shared variable s-{&headkey} like {&head}.{&headkey}.
define new shared variable s-title as character.
define new shared variable s-newrec as logical.
define new shared frame {&framename}.
define var v-max as int64 initial 7.
{menuvar.i new
"s-main = ""MAIN"". s-opt = ""{&option}"". s-page = 1."}
if {&findcon} then s-hideone = false.
              else s-hideone = true.
if {&addcon} then s-hidetwo = false.
             else s-hidetwo = true.
s-page = 1.

run optmenus.
form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 no-box no-label.



{{&formname}.f}

{&start}
main:
repeat:
  hide message.
  clear frame {&framename}.
  {&clearframe}
  view frame {&framename}.
  {&viewframe}
  choose:
  repeat:
    view frame mainhead.
    display s-sign s-menu with no-box no-label frame menu.
    choose field s-menu no-error with frame menu.
    if keyfunction(lastkey) eq "CURSOR-RIGHT" and frame-index eq v-max
    then do:
      if s-sign[2] ne ">" then do:
        bell.
      end.
      else do:
        s-page = s-page + 1.
        run optmenus.
      end.
    end.
    else
    if keyfunction(lastkey) eq "CURSOR-LEFT" and frame-index eq 1
    then do:
      if s-sign[1] ne "<" then do:
        bell.
      end.
      else do:
        s-page = s-page - 1.
        run optmenus.
      end.
    end.
    else
    if keyfunction(lastkey) eq "RETURN" or
       keyfunction(lastkey) eq "GO" then leave choose.
    else do:
      bell.
    end.
  end. /* choose */
  if keyfunction(lastkey) eq "END-ERROR" then leave main.
  if s-page eq 1 and (frame-index eq 1 or frame-index eq 2) then do:
    if frame-index eq 1 and s-menu[1] ne " " then do:
          {&prefind}
                    
          prompt {&head}.{&headkey}
            with frame {&framename}.
            
          find {&head} using input {&head}.{&headkey} no-error.
          if not available {&head} then do:
            {mesg.i 0232}.
            bell. undo, retry.
          end.
          s-{&headkey} = input {&head}.{&headkey}.
          {&postfind}
          pause 0.
    end.
    else
    if frame-index eq 2 and s-menu[2] ne " " then do:
          do transaction on error undo, retry:
            if "{&numprg}" eq "prompt" then do:
              {&preadd}
              prompt {&head}.{&headkey} with frame {&framename}.
              find {&head} using input {&head}.{&headkey} no-error.
              if available {&head} then do:
                {mesg.i 0238}.
                bell. next.
              end.
              s-{&headkey} = input {&head}.{&headkey}.
              hide message.
              create {&head}.
              ASSIGN 
              {&head}.{&headkey} = s-{&headkey}
              {&head}.id = id.
              
            end. /* prompt */
            else do:
              {&preadd}
              run {&numprg}.
              create {&head}.
              {&head}.{&headkey} = s-{&headkey}.
            end.
            {&postadd}
            display {&head}.{&headkey} with frame {&framename}.
            s-newrec = true.
          end. /* error */
    end. /* add */
    run {&subprg} .
    s-newrec = false.
    s-page = 1.
    s-main = "MAIN".
    s-opt = "{&option}".
    run optmenus.
  end.
  else do:
    find optitem where optitem.optmenu eq s-opt
                  and  optitem.ln eq (s-page - 1) * v-max + frame-index - 2.
    if search(optitem.proc + ".r") <> ? then do:
      {&prerun}
      run value(optitem.proc).
      {&postrun}
    end.
    else do:
      {mesg.i 0210}.
    end.
  end.
end. /* main */
{&end}
