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

    METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="transaction_line"}
        RETURN setValuesToBuffer(BUFFER transaction_line:handle).
	END.
/*
PROCEDURE make_transaction_line:
    create transaction_line.
    assign transaction_line.header_id        = jl_header 
           transaction_line.line             = jl_line
           transaction_line.line_status      = jl_status
           transaction_line.gl               = jl_glkon 
           transaction_line.account          = jl_account 
           transaction_line.balance_date     = jl_dat 
           transaction_line.currency         = jl_currency
           
           transaction_line.dc               = jl_oprtype 
           transaction_line.debet            = jl_debet 
           transaction_line.credit           = jl_credit 
           transaction_line.details_template = jl_details 
           
           transaction_line.create_user      = jl_ofc
           transaction_line.create_date      = now
           transaction_line.modify_user      = g-ofc 
           transaction_line.modify_date      = now
           
           
           
           
           
           
           transaction_line.authorize_user   = jl_authorize_user
           transaction_line.authorize_date   = jl_authorize_date
           transaction_line.cif              = jl_cif. 
END PROCEDURE.

*/
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="transaction_line" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER transaction_line:handle).
	END.

    METHOD PUBLIC CHARACTER getDbByHeader(iHeader_id AS INT64):
        {requestItemGetDbByField.f &table="transaction_line" &field="header_id"}
        RETURN getValuesFromBuffer(BUFFER gl:handle).
    END.
 END.