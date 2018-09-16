CLASS transactionLineModel INHERITS dbModel:
    {propertyGetSet.f &name="header_id"        &type="int64"}
    {propertyGetSet.f &name="line"             &type="INTEGER"}
    {propertyGetSet.f &name="line_status"      &type="INTEGER"}
    {propertyGetSet.f &name="line_type"        &type="CHARACTER"}
    {propertyGetSet.f &name="gl"               &type="INT64"}
    {propertyGetSet.f &name="account"          &type="CHARACTER"}
    {propertyGetSet.f &name="balance_date"     &type="DATE"}
    {propertyGetSet.f &name="currency"         &type="CHARACTER"}
    {propertyGetSet.f &name="cif"              &type="CHARACTER"}
    
    {propertyGetSet.f &name="dc"               &type="CHAR"}
    {propertyGetSet.f &name="debet"            &type="DECIMAL"}
    {propertyGetSet.f &name="credit"           &type="DECIMAL"}
    {propertyGetSet.f &name="details"          &type="CHARACTER"}
    {propertyGetSet.f &name="details_template" &type="CHARACTER"}
    {propertyGetSet.f &name="create_user"      &type="CHARACTER"}
    {propertyGetSet.f &name="authorize_user"   &type="CHARACTER"}
    {propertyGetSet.f &name="authorize_date"   &type="DATE"}

    DEFINE VARIABLE tAccount   AS accountModel           NO-UNDO.
    DEFINE VARIABLE tGlAccount AS glAccountModel         NO-UNDO.
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

    DEFINE PUBLIC PROPERTY getGlAccount AS glAccountModel NO-UNDO
        GET:
            InitObjects().
            RETURN tGlAccount.
        END.
        
    CONSTRUCTOR transactionLineModel(iTransactionHeader AS transactionHeaderModel):
        tHeader = iTransactionHeader.
    END.

    CONSTRUCTOR transactionLineModel():
        
    END.
    
    METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="transaction_line"}
        RETURN setValuesToBuffer(BUFFER transaction_line:handle).
	END.

    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="transaction_line" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER transaction_line:handle).
	END.

    METHOD PUBLIC CHARACTER getDbByHeader(iHeader_id AS INT64):
        {requestItemGetDbByField.f &table="transaction_line" &field="header_id"}
        RETURN getValuesFromBuffer(BUFFER gl:handle).
    END.
    
    METHOD PUBLIC OVERRIDE CHARACTER empty():
        RETURN super:empty().
    END.
    
    METHOD PRIVATE CHARACTER setAccount(iAccount AS CHAR):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.

        oError = tAccount:getDbByAccount(iAccount).
        IF oError <> "" THEN RETURN "ERROR-ACCOUNT-" + oError.
        
        gl       = tAccount:gl.
        account  = iAccount.
        currency = tAccount:currency.
        cif      = tAccount:cif.
        
        IF gl <> 0 OR gl <> tGlAccount:gl THEN oError = tGlAccount:getDbByGl(gl).
        
        RETURN oError.
    END.
    
    METHOD PRIVATE CHARACTER InitObjects():
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        IF initDone THEN RETURN "".
        
        IF NOT VALID-OBJECT(tAccount)   THEN tAccount   = NEW accountModel().
        IF NOT VALID-OBJECT(tGlAccount) THEN tGlAccount = NEW glAccountModel().
        IF NOT VALID-OBJECT(tHeader)    THEN tHeader    = NEW transactionHeaderModel().
        
        IF account <> "" OR account <> tAccount:account THEN oError = setAccount(account).
        IF tHeader:header_id = 0 AND header_id > 0      THEN oError = tHeader:getDbByHeader(header_id).
        IF tHeader:header_id = 0                        THEN oError = "ERROR-INVALID-TRANSACTION-HEAD".
        /*initDone = TRUE.*/
        
        RETURN oError.
    END.

    METHOD PUBLIC CHARACTER setLineData(iAccount AS CHARACTER, iDC AS CHARACTER, iAmount AS DECIMAL, iCurrency AS CHARACTER, iDetails AS CHAR):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        
        oError = InitObjects().
        IF oError <> "" THEN RETURN oError.
        
        balance_date = globalSettings:balance_date.

        oError = setAccount(iAccount).
        IF oError <> "" THEN RETURN oError.
        
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