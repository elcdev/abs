USING system.api.core.*.
USING system.api.balance.*.
USING system.api.systemSettings.*.

CLASS system.api.balance.transactionLineModel SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="header_id"        &type="int64" &serializable="serializable"}
    {propertyGetSet.f &name="line"             &type="INTEGER" &serializable="serializable"}
    {propertyGetSet.f &name="line_status"      &type="INTEGER" &serializable="serializable"}
    {propertyGetSet.f &name="line_type"        &type="CHARACTER" &serializable="serializable"}
    
    {propertyGetSet.f &name="gl"               &type="INT64" &serializable="serializable"}
    
    {propertyGetSet.f &name="account"          &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="balance_date"     &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="currency"         &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="cif"              &type="CHARACTER" &serializable="serializable"}
    
    {propertyGetSet.f &name="dc"               &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="debet"            &type="DECIMAL" &serializable="serializable"}
    {propertyGetSet.f &name="credit"           &type="DECIMAL" &serializable="serializable"}
    {propertyGetSet.f &name="details"          &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="details_template" &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="create_user"      &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="authorize_user"   &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="state"            &type="int" &serializable="serializable"}
    

    DEFINE VARIABLE tAccount   AS accountModel           NO-UNDO.
    DEFINE VARIABLE tGlAccount AS glModel                NO-UNDO.
    DEFINE VARIABLE tHeader    AS transactionHeaderModel NO-UNDO.
    DEFINE VARIABLE initDone   AS LOGICAL                NO-UNDO INITIAL FALSE.
    
    DEFINE PUBLIC PROPERTY getAccount AS accountModel NO-UNDO
        GET:
            InitObjects().
            RETURN tAccount.
        END.

    DEFINE PUBLIC PROPERTY getHeader AS transactionHeaderModel NO-UNDO
        GET:
            InitObjects().
            RETURN tHeader.
        END.

    DEFINE PUBLIC PROPERTY getGlAccount AS glModel NO-UNDO
        GET:
            InitObjects().
            RETURN tGlAccount.
        END.
        
    CONSTRUCTOR transactionLineModel(iTransactionHeader AS transactionHeaderModel):
        tHeader = iTransactionHeader.
        empty().
    END.

    CONSTRUCTOR transactionLineModel():
        empty().
    END.
    
    METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="transaction_line" &sequence_id="transaction_id"}
        RETURN setValuesToBuffer(BUFFER transaction_line:handle).
	END.

    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="transaction_line" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER transaction_line:handle).
	END.

    METHOD PUBLIC CHARACTER getDbByHeader(iHeader_id AS INT64):
        {requestItemGetDbByField.f &table="transaction_line" &field="header_id"}
        RETURN getValuesFromBuffer(BUFFER transaction_line:handle). /* ispravil s gl na transaction_line */
    END.
    
    METHOD PUBLIC CHARACTER getDbByHeaderLine(iHeader_id AS INT64 , iLine AS integer):
        {requestItemGetDbByTwoField.f &table="transaction_line" &field="header_id"  &field2="line"}
        RETURN getValuesFromBuffer(BUFFER transaction_line:handle). /* ispravil s gl na transaction_line */
    END.
    
    METHOD PUBLIC OVERRIDE CHARACTER empty():
        super:empty().

        gl          = 0.
        account     = "".
        currency    = "".
        details     = "".
        debet       = 0.0.
        credit      = 0.0.
        state       = 0.
        
        IF VALID-OBJECT(tHeader) 
        THEN DO:
            header_id    = tHeader:header_id.
            balance_date = tHeader:balance_date.
        END.
        
        RETURN "".
    END.
    
    METHOD PRIVATE CHARACTER setAccount(iAccount AS CHAR):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        IF account <> tAccount:account THEN
            oError = tAccount:getDbByAccount(iAccount).
        IF oError <> "" THEN RETURN "ERROR-ACCOUNT-" + oError.
        
        gl       = tAccount:gl.
        account  = iAccount.
        currency = tAccount:currency.
        cif      = tAccount:cif.
        
        IF gl <> 0 OR gl <> tGlAccount:gl THEN oError = tGlAccount:getDbByGl(gl).
        
        RETURN oError.
    END.
    
    METHOD PRIVATE CHARACTER setGlAccount(iGl AS INT64):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.

        oError = tGlAccount:getDbByGl(iGl).
        IF oError <> "" THEN RETURN "ERROR-GL-" + oError.
        
        gl       = tGlAccount:gl.
        
        RETURN oError.
    END.
    
    METHOD PRIVATE CHARACTER InitObjects():
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        IF initDone THEN RETURN "".
        
        IF NOT VALID-OBJECT(tAccount)   THEN tAccount   = NEW accountModel().
        IF NOT VALID-OBJECT(tGlAccount) THEN tGlAccount = NEW glModel().
        IF NOT VALID-OBJECT(tHeader)    THEN tHeader    = NEW transactionHeaderModel().
        
        IF account <> "" OR account <> tAccount:account THEN oError = setAccount(account).
        IF account = "" AND Gl > 0                      THEN oError = setGlAccount(Gl).
        IF tHeader:header_id = 0 AND header_id > 0      THEN oError = tHeader:getDbByHeader(header_id).
        IF tHeader:header_id = 0                        THEN oError = "ERROR-INVALID-TRANSACTION-HEAD".
        /*initDone = TRUE.*/
        
        RETURN oError.
    END.
    METHOD PUBLIC CHARACTER setLineData(iGl AS INT64, iDC AS CHARACTER, iAmount AS DECIMAL, iCurrency AS CHARACTER, iDetails AS CHAR):
        RETURN setLineData(?, iGl, "", iDC, iAmount, iCurrency, iDetails).
    END.
    
    METHOD PUBLIC CHARACTER setLineData(iDate AS DATE, iGl AS INT64, iDC AS CHARACTER, iAmount AS DECIMAL, iCurrency AS CHARACTER, iDetails AS CHAR):
        RETURN setLineData(iDate, iGl, "", iDC, iAmount, iCurrency, iDetails).
    END.
    
    METHOD PUBLIC CHARACTER setLineData(iAccount AS CHARACTER, iDC AS CHARACTER, iAmount AS DECIMAL, iCurrency AS CHARACTER, iDetails AS CHAR):
        RETURN setLineData(?, 0, iAccount, iDC, iAmount, iCurrency, iDetails).
    END.
    
    METHOD PUBLIC CHARACTER setLineData(iDate AS DATE, iAccount AS CHARACTER, iDC AS CHARACTER, iAmount AS DECIMAL, iCurrency AS CHARACTER, iDetails AS CHAR):
        RETURN setLineData(iDate, 0, iAccount, iDC, iAmount, iCurrency, iDetails).
    END.
    
    METHOD PUBLIC CHARACTER setLineData(iGl AS int64, iAccount AS CHARACTER, iDC AS CHARACTER, iAmount AS DECIMAL, iCurrency AS CHARACTER, iDetails AS CHAR):
        RETURN setLineData(?, iGl, iAccount, iDC, iAmount, iCurrency, iDetails).
    END.
    
    METHOD PUBLIC CHARACTER setLineData(iDate AS DATE, iGl AS INT64, iAccount AS CHARACTER, iDC AS CHARACTER, iAmount AS DECIMAL, iCurrency AS CHARACTER, iDetails AS CHAR):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        
        oError = InitObjects().
        IF oError <> "" THEN RETURN oError.
        IF iDate = ? THEN balance_date = globalSettings:balance_date.
        ELSE DO:
            IF iDate > TODAY THEN RETURN "ERROR-TRANSACTION-DATE".
            oError = closedDaysApi:validBalanceDate(iDate).
            IF oError <> "" THEN RETURN oError.
            balance_date = iDate.
        END.  
       
        IF iAccount <> "" THEN 
         DO:
            oError = setAccount(iAccount).
            IF oError <> "" THEN RETURN oError.
         END.
        ELSE IF iGl > 0 THEN 
         DO:
            oError = setGlAccount(iGl).
            IF oError <> "" THEN RETURN oError.
         END.
        ELSE 
         DO:
            RETURN "ERROR-NO-ACCOUNTS".
         END.
        
        dc = iDc.
        oError = transactionCore:validateDc(iDC).
        IF oError <> "" THEN RETURN oError.

        CASE iDC:
            WHEN "D" THEN debet  = iAmount.
            WHEN "C" THEN credit = iAmount.
        END.
        
        oError = InitObjects().
        IF oError <> "" THEN RETURN oError.

        currency     = iCurrency.
        details            = iDetails. /* TODO! Make traslates to local language */
        details_template   = iDetails.
        
        RETURN "". 
    END.
 END.