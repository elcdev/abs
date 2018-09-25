USING system.api.core.*.
USING system.api.stomp.*.

CLASS system.api.stomp.stompSettings SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="host"      &type="character" &serializable="serializable"}
    {propertyGetSet.f &name="port"      &type="character" &serializable="serializable"}
    {propertyGetSet.f &name="user"      &type="character" &serializable="serializable"}
    {propertyGetSet.f &name="password"  &type="character" &serializable="serializable"}
    
    {dbModelJsonParser.f &class="system.api.stomp.stompSettings"}
        
    DEFINE STATIC VARIABLE settingsFileName AS CHARACTER NO-UNDO INITIAL "config/stomp_mq.conf".
    
    CONSTRUCTOR stompSettings():
        IF host = "" OR port = "" THEN 
         DO:
            host       = "localhost!!!!".
            port       = "61613".
            IF user = ""     THEN user       = "guest".
            IF password = "" THEN password   = "guest".
         END.
    END.
    
    METHOD PUBLIC STATIC system.api.stomp.stompSettings getStompSettings():
        IF SEARCH(settingsFileName) <> ? THEN settingsFileName = SEARCH(settingsFileName).
        RETURN parseJsonFile(settingsFileName).
    END.
    
    METHOD PUBLIC CHARACTER saveSettings():
        toJsonFile(settingsFileName).
        RETURN "".
    END.
    
END.

