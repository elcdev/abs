USING system.api.core.*.
USING system.api.payments.*.
USING system.api.systemSettings.*.

CLASS system.api.payments.paymentTemplateModel SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="name"                &type="CHAR"}
    {propertyGetSet.f &name="description"         &type="CHAR"}
    {propertyGetSet.f &name="payment_type"        &type="CHAR"}
    {propertyGetSet.f &name="payment_subtype"     &type="CHAR"}
    {propertyGetSet.f &name="payment_status"      &type="CHAR"}
    {propertyGetSet.f &name="edit_form"           &type="CHAR"}
    
    METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="payment_template"}
        RETURN setValuesToBuffer(BUFFER payment_template:handle).
	END.

    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="payment_template" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER payment_template:handle).
	END.
    
	DEF VAR transactionLineGeneratorClassName AS CHAR /* = TemplateRemitance*/.
	
    DEF TEMP-TABLE template_fields LIKE payment_template_data.
    
    /*
    table template_header
	id
	name
	description
	paymentType
	paymentSubType
    form
	
	
table template_fields
	template_id
	field_name = model field name in class
	field_description = decription  (label)
	field_type = char/dec/date
    field_format=
	field_value = value/formula
	field_action = editable/hidden/readonly/calculated
	
    */
    
    
    /*details="Elektrum, reg.Nr.2222222, Re.Nr:%rekina_numurs%"    */
END.

/*
====================================================
Schet: XXXXXX
Summa za electrichestvo, EUR: >>>>>>>>.99
Nomer Scheta: XXXXX-XX
*/
