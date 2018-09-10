/*
 MENU: 13-1-8-1
 GLFILE
 glsetsub.p
*/
{global.i } 
/*
{glsetvar.i "new shared"}
*/
DEFINE VARIABLE id AS INT64.
DEFINE BUFFER bgl_balance FOR gl_balance.
{sub.i
&option="GLSUB"
&head="gl"
&headkey="gl"
&framename="gl"
&formname="gl"
&updatecon="true"
&deletecon="true"
&start=" "
&display="display gl.gl gl.description gl.short_name gl.gl_type gl.subledger_type gl.total_acc gl.parent_gl
gl.level gl.restrict_operation gl.gl_status with frame gl."

&preupdate ="
update gl.des with frame gl.
if gl.short_name eq """" then do:
    gl.short_name = gl.description.
    display gl.short_name with frame gl.
end.
if gl.gl_status = '' then gl.gl_status = 'Active'.
update gl.short_name gl.gl_type gl.subledger_type gl.total_acc gl.parent_gl
gl.level gl.restrict_operation gl.gl_status with frame gl."
&update=" "
&postupdate="find first gl_balance where gl_balance.gl = gl.gl NO-LOCK NO-ERROR.
            if not available gl_balance then do:
                for each crc where crc.sts ne 9 no-lock:
                    find last bgl_balance no-lock use-index id no-error.
                    if not available bgl_balance then id = 1. else id = bgl_balance.id + 1.
                    create gl_balance.
                    assign 
                           gl_balance.id = id
                           gl_balance.gl = gl.gl
                           gl_balance.currency = crc.code
                           gl_balance.balance_date = g-today
                           gl_balance.create_user = g-ofc
                           gl_balance.create_date = now.
                end.
            end.
    
"
&predelete=" "
&postdelete=" "
&end=" "
}
