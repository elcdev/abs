USING system.api.*.
USING system.api.balance.*.
USING system.api.currency.*.
USING system.api.menu.*.
USING system.api.payments.*.
USING system.api.core.*.

CLASS system.api.apiHelper:
    
    /* Get model class name by apiCall name */
    METHOD PUBLIC STATIC CHARACTER getClassName(iApiCall AS CHARACTER):
        CASE iApiCall:
            WHEN "update.account"                THEN RETURN "system.api.balance.accountModel".
            WHEN "update.gl"                     THEN RETURN "system.api.balance.glModel".
            WHEN "update.transaction.header"     THEN RETURN "system.api.balance.transactionHeaderModel".
            WHEN "update.transaction.line"       THEN RETURN "system.api.balance.transactionLineModel".
            WHEN "update.currency"               THEN RETURN "system.api.currency.currencyModel".
            WHEN "update.currency.rate"          THEN RETURN "system.api.currency.currencyRateModel".
            WHEN "update.menu.item"              THEN RETURN "system.api.menu.menuItemModel".
            WHEN "payment.convertation"          THEN RETURN "system.api.payments.paymentConvertationModel".
            WHEN "payment.internal"              THEN RETURN "system.api.payments.paymentInternalModel".
            WHEN "payment.template"              THEN RETURN "system.api.payments.paymentTemplateModel".
        END CASE.
        
        RETURN "system.api.core.dbModel".
    END.
    
    /* Create model by class name */
    METHOD PUBLIC STATIC Progress.Lang.Object getModel(iClassName AS CHARACTER):
        DEFINE VARIABLE oObject AS Progress.Lang.Object.
        oObject = DYNAMIC-NEW iClassName ().
        RETURN oObject.
    END.
    
    /* Create model by apiCall name */
    METHOD PUBLIC STATIC Progress.Lang.Object getApiModel(iApiCall AS CHARACTER):
        RETURN getModel(getClassName(iApiCall)).
    END.
    
    METHOD PUBLIC STATIC Progress.Lang.Object getApiModel(iApiCall AS CHARACTER, iJson AS LONGCHAR):
        DEFINE VARIABLE className AS CHARACTER.
        
        className = getClassName(iApiCall).
        
        IF INDEX(iJson, iApiCall) > 0 
        THEN DO:
            iJson = REPLACE(iJson, iApiCall, className).
        END.
        ELSE DO:
            iJson = CHR(123) + '"' + className + '":' + iJson + CHR(125).
        END.
        
        RETURN dbModel:fromJson(iJson, className).
    END.
END.