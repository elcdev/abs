{global.i}
def buffer bgl_balance for gl_balance.
def var id as int64.

for each gl no-lock:
    find first gl_balance where gl_balance.gl = gl.gl no-lock no-error.
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
end.