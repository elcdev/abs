USING system.api.stomp.*.

def var myCnt   as int  no-undo.
def var myStomp AS stompConnector.

PAUSE 0 BEFORE-HIDE.

myStomp = new stompConnector().
myStomp:connect().
myStomp:SetMessageHandlerProcedure("messagehandler", this-procedure).
myStomp:doSubscribe("/queue/currencyUpdates").
myStomp:listenForMessages().
myStomp:disconnect(myStomp:ConnectionId).

procedure messagehandler:
    def input param iQueue   as char no-undo.    
    def input param iMessage as char no-undo.    

    MESSAGE iMessage VIEW-AS ALERT-BOX.
    myCnt = myCnt + 1.
end procedure. /* messagehandler */

MESSAGE "Done" VIEW-AS ALERT-BOX.