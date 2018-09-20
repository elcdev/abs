CLASS paymentConstants:
    {propertyGetSet.f &name="payment_internal_fee_gl"           &type="INT64"        &static=static}
    {propertyGetSet.f &name="payment_internal_fee_details"      &type="CHARACTER"    &static=static}

    {propertyGetSet.f &name="conversion_gl"                     &type="INT64"        &static=static}
    {propertyGetSet.f &name="conversion_income_gl"              &type="INT64"        &static=static}
    {propertyGetSet.f &name="conversion_details"                &type="CHARACTER"    &static=static}
    {propertyGetSet.f &name="national_currency"                 &type="CHARACTER"    &static=static}


    
    CONSTRUCTOR STATIC paymentConstants():
        payment_internal_fee_gl = 60220000.
        payment_internal_fee_details="[[Payment fee for &1]]".
        conversion_gl               = 11402600.
        conversion_income_gl        = 60410000.
        conversion_details          = "[[Conversion income for deal &1]]".
        national_currency           = "EUR". /* -> to Global settings */
    END.
END.