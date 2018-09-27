USING system.api.core.*.
USING system.api.balance.*.
USING system.api.systemSettings.*.
USING system.api.clients.*.

CLASS system.api.balance.accountModel SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="gl"                  &type="int64" &serializable="serializable"}
    {propertyGetSet.f &name="iban"                &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="account"             &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="base_account"        &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="overdraft_account"   &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="currency"            &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="account_group"       &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="subledger_type"      &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="account_subtype"     &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="product_code"        &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="branch"              &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="cif"                 &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="client_id"           &type="int64" &serializable="serializable"}
    {propertyGetSet.f &name="account_status"      &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="description"         &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="open_date"           &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="close_date"          &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="open_amount"         &type="DEC" &serializable="serializable"}
    {propertyGetSet.f &name="last_operation_date" &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="last_debet_date"     &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="last_debet_amount"   &type="DEC" &serializable="serializable"}
    {propertyGetSet.f &name="last_credit_date"    &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="last_credit_amount"  &type="DEC" &serializable="serializable"}

    {dbModelJsonParser.f &class="system.api.balance.accountModel"}
    {dbModelPutGetMethods.f &TABLE="account" &override=""}
    
    METHOD PUBLIC CHARACTER getDbByAccount(iAccount AS CHAR):
        {requestItemGetDbByField.f &table="account" &field="Account"}
        RETURN getValuesFromBuffer(BUFFER account:handle).
    END.

    METHOD PUBLIC OVERRIDE CHARACTER prepare():
        DEFINE VARIABLE tId    AS INT64 NO-UNDO.
        
        tId = accountCore:getAccountId(account).
        IF tId > 0              THEN id = tId. 
        IF iban = ""            THEN accountCore:generateIban(account).
        IF base_account = ""    THEN base_account = account.
        IF cif = "" AND base_account <> "" AND base_account <> account THEN cif = accountCore:getAccountCif(base_account).
        IF cif <> "" AND client_id = 0 THEN client_id = clientCore:getClientId(cif). /* TODO */
        IF account_status = ""  THEN account_status = accountStatusEnum:active.
        IF account_group = ""   THEN account_group  = accountGroupEnum:default.
        IF subledger_type = ""  THEN subledger_type = subledgerTypeEnum:default.
        
        RETURN "".
    END.

    METHOD PUBLIC OVERRIDE CHARACTER validate():
        DEFINE VARIABLE tId    AS INT64 NO-UNDO.
        
        DO ON ERROR UNDO, THROW:
            IF gl < 1 
            THEN 
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-NO-GL, Check gl of account!", 501).
            
            IF iban = "" 
            THEN
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-NO-IBAN, Check iban of account!", 501).
            
            IF base_account = "" 
            THEN
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-NO-BASE-ACCOUNT, Check base account!", 501).
            
            IF base_account <> "" AND base_account <> account AND NOT accountCore:isValidAccount(base_account)
            THEN
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-INVALID-BASE-ACCOUNT, Check base account!", 501).

            IF overdraft_account <> "" AND NOT accountCore:isValidAccount(overdraft_account)
            THEN
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-INVALID-BASE-ACCOUNT, Check base account!", 501).
                
            IF subledger_type <> "" AND NOT accountCore:isValidSubledger(subledger_type)
            THEN
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-ACCOUNT-SUBLEDGER, Check account subledger type!", 501).
            
            IF cif = "" 
            THEN
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-ACCOUNT-CIF, Check account client identifier!", 501).
                
            IF NOT accountStatusEnum:isValid(account_status) 
            THEN 
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-ACCOUNT-STATUS, Check account status!", 501).
            
            IF NOT accountGroupEnum:isValid(account_group) 
            THEN 
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-ACCOUNT-GROUP, Check account group!", 501).

            IF NOT subledgerTypeEnum:isValid(subledger_type) 
            THEN 
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-ACCOUNT-GROUP, Check account group!", 501).
                
            IF open_date = ? 
            THEN
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-ACCOUNT-OPEN-DATE, Check account open date!", 501).
            
            IF close_date < open_date 
            THEN
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-ACCOUNT-CLOSE-DATE, Check account close date >= open date!", 501).
            
        END.
        
        RETURN "".
    END.


END.