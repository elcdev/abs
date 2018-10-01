USING system.api.currency.*.
USING system.api.core.*.
USING system.api.systemSettings.*.

CLASS system.api.clients.clientModel SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="cif"                 &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="full_name"           &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="first_name"          &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="last_name"           &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="client_group"        &type="CHAR" &serializable="SERIALIZABLE"}
    {propertyGetSet.f &name="client_type"         &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="birth_day"           &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="sex"                 &type="CHAR" &serializable="SERIALIZABLE"}
    {propertyGetSet.f &name="registration_number" &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="client_status"       &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="registration_date"   &type="DATE" &serializable="SERIALIZABLE"}
    {propertyGetSet.f &name="registration_user"   &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="activation_date"     &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="activation_user"     &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="close_date"          &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="close_user"          &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="residence_country"   &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="ext_client_id"       &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="scoring_risk_group"  &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="scoring_points"      &type="INT"  &serializable="serializable"}
    
    {dbModelJsonParser.f &class="system.api.clients.clientModel"}

    METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="client"}
        
        /* TODO! Move into include */
        oError = validate().
        IF oError <> "" THEN RETURN oError.
        
        RETURN setValuesToBuffer(BUFFER client:handle).
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="client" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER client:handle).
	END.
    
    METHOD PUBLIC CHARACTER getDbByCif(iCif AS CHAR):
        {requestItemGetDbByField.f &table="client" &field="cif"}
        RETURN getValuesFromBuffer(BUFFER client:handle).
    END.
    
    METHOD PUBLIC CHARACTER getDbByRegNr(iRegistration_number AS CHAR):
        {requestItemGetDbByField.f &table="client" &field="registration_number"}
        RETURN getValuesFromBuffer(BUFFER client:handle).
    END.
    /* TODO
    METHOD PUBLIC OVERRIDE CHARACTER prepare():
        DEFINE VARIABLE tId    AS INT64 NO-UNDO.
        
        tId = clientApi:getClientId(client).
        IF tId > 0 AND id = 0 THEN id = tId. /* TODO! */
        
        RETURN "".
    END.
    */
    METHOD PUBLIC OVERRIDE CHARACTER validate():
        DEFINE VARIABLE tId    AS INT64 NO-UNDO.
        DEFINE VARIABLE oError AS CHARACTER.
        
        DO ON ERROR UNDO, THROW:
            IF cif = "" OR cif = ? OR LENGTH(cif) < 8 THEN UNDO, THROW NEW Progress.Lang.AppError("ERROR-CIF-CODE, Cif length < 8!", 501).
            
            IF full_name = "" OR LENGTH(full_name) < 3 THEN UNDO, THROW NEW Progress.Lang.AppError("ERROR-CLIENT-FULLNAME", 502).
            
            IF first_name = "" OR LENGTH(first_name) < 2 THEN UNDO, THROW NEW Progress.Lang.AppError("ERROR-CLIENT-FIRSTNAME", 503).  
            
            IF first_name = "" OR LENGTH(first_name) < 2 THEN UNDO, THROW NEW Progress.Lang.AppError("ERROR-CLIENT-LASTNAME", 504).         
            
            IF birth_day NE ? AND (birth_day > TODAY OR YEAR(birth_day) < YEAR(TODAY) - 120)THEN UNDO, THROW NEW Progress.Lang.AppError("ERROR-BIRTHDAY", 505).
                                                
            IF sex NE "F" AND sex NE "M" AND sex NE "N" AND sex NE "" 
            THEN DO:
                oError = "INCORRECT-GENDER".
                UNDO, THROW NEW Progress.Lang.AppError(oError, 506).
            END.
            
            IF residence_country = "" OR residence_country = ? OR LENGTH(residence_country) NE 2
            THEN DO:
                oError = "ERROR-RESIDENCE-COUNTRY!".
                UNDO, THROW NEW Progress.Lang.AppError(oError, 507).
            END.
            
            IF scoring_points < 0
            THEN DO:
                oError = "ERROR-SCORING-POINTS!".
                UNDO, THROW NEW Progress.Lang.AppError(oError, 508).
            END.
        END.
        
        RETURN oError.
    END.
END.