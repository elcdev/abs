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

    DEFINE VARIABLE tAccount AS accountModel.
    
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
    
    METHOD PUBLIC CHARACTER empty ():
        /* super:empty(). */
        
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER setAccount(iAccount AS CHAR):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        DEFINE VARIABLE tAccount AS accountModel.
        
        tAccount = NEW accountModel().
        oError = tAccount:getDbByAccount(iAccount).
        IF oError <> "" THEN RETURN oError.
        
        gl       = tAccount:gl.
        account  = iAccount.
        currency = tAccount:currency.
        cif      = tAccount:cif.
        
        RETURN "".
    END.
    
    METHOD STATIC PRIVATE CHARACTER validateDc(iDC AS CHAR):
        IF INDEX("D,C,", iDC + ",") < 1 THEN RETURN "ERROR-INVALID-DC-VALUE".
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER setLineData(iAccount AS CHARACTER, iDC AS CHARACTER, iAmount AS DECIMAL, iCurrency AS CHARACTER, iDetails AS CHAR):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        
        oError = setAccount(iAccount).
        IF oError <> "" THEN RETURN oError.
        
        oError = validateDc(iDC).
        IF oError <> "" THEN RETURN oError.
        dc = iDc.
        
        CASE iDC:
            WHEN "D" THEN debet  = iAmount.
            WHEN "C" THEN credit = iAmount.
        END.
        
        currency     = iCurrency.
        details      = iDetails.
        balance_date = globalSettings:balance_date.
        
        RETURN "". 
    END.
 END.