/* f_ofcp.p */
define input parameter cur_proc as character.
define input parameter fl_quit as logical.
define variable cur_proc_old as character.
define variable cur_pts as character.
define variable cur_ws as character.
define variable cur_ofc as character.
define variable cur_whn as date.
define variable cur_tim as int64.
define variable s1 as character.
define variable s2 as character.
define variable s3 as character.
def var i as int64.
def var spc as dec.
def var lim as dec.
def var str as char extent 12.
def var islog as log.
def var logfile as char.
{global.i}
if not g-WriteMode then do:
  /* history_file */
  leave.
end.
DEF BUFFER sysc FOR bank.sysc.
find sysc where sysc.sysc eq "LOGLIM" no-lock no-error.
if available sysc then do:
  lim = sysc.deval.
  logfile = sysc.chval.
end.
else do:
  lim = 5.00.
  logfile = "/bank1/rep/nmlog.txt".
end.
cur_proc_old = "".
cur_whn = today.
cur_tim = time.
input through who am i no-echo.
import ^ ^ ^ ^ s1 s2.
input close.
if s2 = "" then cur_ws = s1. else cur_ws = s2.
if cur_ws begins "(" then cur_ws = substring(cur_ws,2).
cur_ws = entry(1,cur_ws,")").
find first _MyConnection no-lock.
find first _Connect where _Connect._Connect-Usr = _MyConnection._MyConn-UserId no-lock.
cur_ofc = _Connect._Connect-Name.
cur_pts = replace(_Connect._Connect-Device + " " + trim(string(_Connect._Connect-Pid))," ","/").
if cur_pts <> "" then do:
  find ofcp where ofcp.pts = cur_pts use-index pts no-lock no-error.
  if available ofcp then do:
    if fl_quit then do:
      find ofcp where ofcp.pts = cur_pts use-index pts no-error.
      if available ofcp then do:
        delete ofcp.
      end.
    end.
    else do:
      if ofcp.proc <> cur_proc or ofcp.ofc <> cur_ofc then do:
        find ofcp where ofcp.pts = cur_pts use-index pts no-error.
        if available ofcp then do:
          if ofcp.ofc <> cur_ofc then do:
            assign ofcp.ws   = cur_ws
                   ofcp.ofc  = cur_ofc
                   ofcp.proc = cur_proc
                   ofcp.whn  = cur_whn
                   ofcp.tim  = cur_tim.
          end.
          else do:
            assign cur_proc_old = ofcp.proc.
            assign ofcp.proc = cur_proc
                   ofcp.whn  = cur_whn
                   ofcp.tim  = cur_tim.
          end.
        end.
        find ofcp where ofcp.pts = cur_pts use-index pts no-lock no-error.
      end.
      else cur_proc_old = ofcp.proc.
    end.
  end.
  else do:
    if not fl_quit then do:
      create ofcp.
      assign ofcp.pts  = cur_pts
             ofcp.ws   = cur_ws
             ofcp.ofc  = cur_ofc
             ofcp.proc = cur_proc
             ofcp.whn  = cur_whn
             ofcp.tim  = cur_tim.
    end.
  end.
end.

input through /usr/bin/uptime.
import str.
input close.
islog = no.
do i = 10 to 12:
  spc = decimal(trim(trim(str[i],","))) no-error.
  if spc ne ? and
     spc ge lim then islog = yes.
end.
if islog and search(logfile) ne ? then do:
  output to value(logfile) append.
  put cur_whn format "99/99/9999" " "
      string(cur_tim,"hh:mm:ss") " "
      cur_ofc " "
      cur_pts format "x(7)" " "
      cur_ws format "x(17)" " ".
  if fl_quit then put "QUIT" at 68.
  else if cur_proc_old ne "" then put cur_proc_old format "x(8)"
                                      "STOP" at 68.
  else do:
    if cur_proc eq "" then put "MENU".
    else put cur_proc format "x(8)".
    put "START" at 68.
  end.
  put skip.
  output close.
end.
run nm_cnt.r(cur_proc).
