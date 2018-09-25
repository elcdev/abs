USING system.api.stomp.*.

CLASS system.api.stomp.stompConnector:
    DEFINE PRIVATE VARIABLE pSocketHandle AS HANDLE NO-UNDO.
    DEFINE PRIVATE VARIABLE pHandlerProc  AS HANDLE NO-UNDO.
    DEFINE PRIVATE VARIABLE msghndproc    AS CHARACTER INITIAL ? NO-UNDO.
    DEFINE PRIVATE VARIABLE msghndhnd     AS HANDLE    NO-UNDO.
    
    define public variable PortName as character initial "61613" no-undo.
    define public variable HostName as character initial "localhost" no-undo.
    define public variable ConnectionId as char no-undo.

    DEFINE VARIABLE Logfile          AS system.api.stomp.Logger.
    DEFINE VARIABLE pEnableListener  AS LOG INITIAL TRUE.
    DEFINE VARIABLE Settings         AS stompSettings.
    
    CONSTRUCTOR PUBLIC stompConnector( ): 
        Settings = stompSettings:getStompSettings().
        Logfile = new system.api.stomp.logger("stomp").
        Logfile:WriteMessage(3, "constructed").
    END CONSTRUCTOR.
    
    DESTRUCTOR PUBLIC stompConnector( ): 
      
        IF VALID-HANDLE(pSocketHandle) 
        THEN DO:
            pSocketHandle:disconnect().
            DELETE OBJECT pSocketHandle.
        END.
        
        IF valid-handle(pHandlerProc) 
        THEN DELETE PROCEDURE pHandlerProc.
        Logfile:WriteMessage(3, "destructed").
        
        DELETE OBJECT Settings NO-ERROR.
    END DESTRUCTOR.

    METHOD PUBLIC VOID connect():
        CONNECT(Settings:host, Settings:port, Settings:USER, Settings:password).
    END.
    
    METHOD PUBLIC VOID connect(
                input iHostName as char,
                input iPort as char,
                input iUserName as char,
                input iPassword as char
                ):

        def var lFrame as char no-undo.
        HostName = iHostName.
        PortName = iPort.
        tcpConnect().
        lFrame = subst("CONNECT&1login: &2&1passcode:&3&1&1", chr(10), iUserName, iPassword).
        sendFrame(lFrame).
        
        waitfor(0).
    END METHOD.
    
    method public void processData(
        input iSocket as handle, 
        input iData as char
        ):

        case entry(1, iData, chr(10)):
            when "CONNECTED" then processConnected(iSocket, iData).
            when "MESSAGE" then processMessage(iSocket, iData).
        end case.
    end method.
    
    method private void processConnected(
        input iSocket as handle, 
        input iData as char
        ):
        def var lLine as char no-undo.
        def var lCnt as int no-undo.

        do lCnt = 1 to num-entries(iData, chr(10)):
            lLine = entry(lCnt, iData, chr(10)).
            if lLine begins "session:id:" 
            then ConnectionId = substring(lLine, 12).
        end.

    end method.

    method private void processMessage(
            input iSocket as handle, 
            input iData   as char
            ):
        def var lLine      as char no-undo.
        def var lCnt       as int no-undo.
        def var lQueue     as char no-undo.
        def var lTimeStamp as char no-undo.
        def var lPriority  as int  no-undo.
        def var lInMessage as log  no-undo.
        def var lMessage   as char no-undo.
        
        DO lCnt = 1 TO NUM-ENTRIES(iData, chr(10)):
            lLine = entry(lCnt, iData, chr(10)).
            
            IF lInMessage 
            THEN lMessage = lMessage + "~n" + lLine.
            
            ELSE DO:
                if lLine begins "destination:" 
                then lQueue = substring(lLine, 13).
                else if lLine = "" then lInMessage = yes.
            END.
        END.
        
        IF VALID-HANDLE(msghndhnd) THEN RUN VALUE(msghndproc) in msghndhnd (lQueue, lMessage).
        
    END METHOD.

    METHOD PRIVATE VOID sendFrame(
            input iFrame as char
            ):

        def var lMemPtr   as memptr no-undo.
        def var lNumBytes as int no-undo.
        
        lNumBytes = length(iFrame).
        set-size(lMemPtr) = lNumBytes + 1. /* add 1 bytes for 0-terminated string */
        put-string(lMemPtr, 1) = iFrame. 
    
        error-status:error = no.
        pSocketHandle:write(lMemPtr, 1, lNumBytes + 1 /*get-size(lMemPtr) */) no-error.
        set-size(lMemPtr) = 0.
    
        if error-status:error
        then do:
            Logfile:writeMessage(1, error-status:get-message(1)).
            return error.
        end.
        else Logfile:writeMessage(3, subst("Outbound~n&1", iFrame)).

    end method.

    method public void abort (
        input iTransactionId as char
        ):
        def var lFrame as char no-undo.
    
        lFrame = subst("ABORT&1transaction: &2&1&1", chr(10), iTransactionId).
        sendFrame(lFrame).
    end method.

    method public void begin(
        input iTransactionId as char
        ):

        def var lFrame as char no-undo.
        
        lFrame = subst("BEGIN&1transaction: &2&1&1", chr(10), iTransactionId).
        sendFrame(lFrame).
    
    end method.

    method public void commit(
        input iTransactionId as char
        ):

        def var lFrame as char no-undo.
        
        lFrame = subst("COMMIT&1transaction: &2&1&1", chr(10), iTransactionId).
        sendFrame(lFrame).
    
    end method.



    method public void setMessageHandlerProcedure(
        input iProcName   as char,
        input iProcHandle as handle
        ):
        msghndproc = iProcName.
        msghndhnd = iProcHandle.
    end method.

    method public void waitfor(
        input iPauseSec as deci
        ):
        wait-for read-response of pSocketHandle pause iPauseSec.
    end method.

    method public void disconnect(
        input iConnectionId as char
        ):
        
        def var lFrame as char no-undo.
        
        lFrame = subst("DISCONNECT&1&1", chr(10), iConnectionId).
        sendFrame(lFrame).
    
    end method.

    method public void sendText(
        input i-queue   as char,
        input i-message as char
        ):
        
        def var lFrame as char no-undo.
        lFrame = subst("SEND&1destination: &2&1persistent:true&1&1&3&1", chr(10), i-queue, i-message).
        sendFrame(lFrame).
        
    end method.
    
    method public void doSubscribe(
        input i-queue as char):
        dosubscribe(i-queue, "auto").
    end method.

    method public void doSubscribe(
        input i-queue as char,
        input i-ack   as char
        ):

        def var lFrame as char no-undo.
        
        lFrame = subst("SUBSCRIBE&1destination: &2&1ack:&3&1&1", chr(10), i-queue, i-ack).
        sendFrame(lFrame).
        EnableListener().
    end method.

    method public void unsubscribe(
        input i-queue as char
        ):
    
        def var lFrame as char no-undo.
        
        lFrame = subst("UNSUBSCRIBE&1destination: &2&1&1", chr(10), i-queue).
        sendFrame(lFrame).
    
    end method.

    method private log tcpConnect() :
        Logfile:WriteMessage(3, subst("connect -H &1 -S &2", HostName, PortName)).
        if not valid-handle(pSocketHandle) 
        then do:
            create socket pSocketHandle.
            
            run system/api/stomp/stompSocketProc.p persistent set pHandlerProc
                (this-object, logFile).
            pSocketHandle:SET-READ-RESPONSE-PROCEDURE("tcp_readhandler",
                pHandlerProc).
        end.

        if pSocketHandle:connect(subst("-H &1 -S &2", HostName, PortName))
        then Logfile:writeMessage(3, subst("Connection to &1 port &2", HostName, PortName)).
        else Logfile:writeMessage(1, subst("Failed to connect to &1 port &2", HostName, PortName)).

        EnableListener().
    END METHOD.

    METHOD PUBLIC VOID EnableListener():
        pEnableListener = TRUE.
    END.
    
    METHOD PUBLIC VOID DisableListener():
        pEnableListener = FALSE.
    END.
    
    METHOD PUBLIC CHARACTER listenForMessages():
        DEFINE VARIABLE startdt AS DATETIME NO-UNDO.
        
        PAUSE 0 BEFORE-HIDE.
        startdt = NOW.
        
        DO WHILE INTERVAL(NOW, startdt, "seconds") < 1000 AND pEnableListener:
            waitfor(1).
            PROCESS EVENTS.
        END.
        
        RETURN "".
    END.
end class.
