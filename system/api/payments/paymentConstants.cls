CLASS paymentConstants:
    {propertyGetSet.f &name="payment_internal_fee_gl"              &type="INT64"        &static=static}
    {propertyGetSet.f &name="payment_internal_fee_details"          &type="CHARACTER"    &static=static}
    
    CONSTRUCTOR STATIC paymentConstants():
        payment_internal_fee_gl = 60220000.
        payment_internal_fee_details="[[Payment fee for &1]]".
    END.
END.