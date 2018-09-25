    USING system.api.core.*.
    USING system.api.balance.*.
    USING system.api.stomp.*.
    
    session:appl-alert = yes.
    session:system-alert = yes.
    session:debug-alert = yes.
    
    DEFINE VARIABLE tAccount AS accountModel.
    DEFINE VARIABLE myStomp  AS stompConnector.
    DEFINE VARIABLE l-cnt    AS INTEGER.
    
    tAccount = NEW accountModel().
    
    myStomp = new stompConnector().
    myStomp:connect().
    
    do l-cnt = 1 to 10:
    /*
        myStomp:sendtext("/queue/currencyUpdates", 
                         subst("Hello world &1 &2", l-cnt, iso-date(now))).
      */                   
        tAccount:getDb(1).
        myStomp:sendtext("/queue/currencyUpdates", STRING(tAccount:toJson())).
    end.

    myStomp:waitfor(1).
    myStomp:disconnect(myStomp:ConnectionId).

    DELETE OBJECT myStomp.
    DELETE OBJECT tAccount.