USING system.api.stomp.*.

def input param mystomp as stompConnector no-undo.
def input param LogFile as Logger no-undo.

def var gDataString as char no-undo.

procedure tcp_readhandler:

    def var lMemPtr as memptr no-undo.
    def var lBytesAvailable as int  no-undo.
    def var lDataString as char no-undo.
    def var lStartPos as int no-undo.
    def var lDataLength as int no-undo.
 
/*  Comment by Julian Lyndon-Smith about the setting of sensitive
    this is needed to stop the read trigger from firing whilst processing
    in theory this should not be needed, but after suggestions from Greg Higgins
    and experimentation it seems to be the "chicken soup" solution for sockets
    that READKEY PAUSE 0 is for other areas */
    self:sensitive = no.

    error-status:error = no.
    lBytesAvailable = self:get-bytes-available() no-error.
    if error-status:error
    then Logfile:WriteMessage(1, error-status:get-message(1)).
    else do:
        set-size(lMemPtr) = lBytesAvailable + 1. /*add 1 byte for 0 terminated string*/
        error-status:error = no.
        self:read(lMemPtr, 1, lBytesAvailable, READ-EXACT-NUM) no-error.
        if error-status:error
        then Logfile:WriteMessage(1, error-status:get-message(1)).
        else do:
            lStartPos = 1.
            do while lStartPos < lBytesAvailable:
                lDataString = get-string(lMemPtr, lStartPos).
                lDataLength = length(lDataString, "RAW").
                Logfile:WriteMessage(4, subst("Inbound pos:&1 size:&2~n&3",
                    lStartPos, lDataLength, lDataString)).
                /*{ dbgstart.t }*/
                assign
                    lStartPos = lStartPos + lDataLength
                    gDataString = gDataString + lDataString
                    lDataString = "".

                if lStartPos <= lBytesAvailable and get-byte(lMemPtr, lStartPos) = 0
                then do:
                     gDataString = trim(gDataString).
                     Logfile:WriteMessage(3, subst("Process ~n&1",  gDataString)).
                     mystomp:ProcessData(self, gDataString).
                     gDataString = "".
                end.
                lStartPos = lStartPos + 1.
            end.
            set-size(lMemPtr) = 0.
        end.
    end.
    self:sensitive = yes.

end procedure. /* tcp_readhandler */
