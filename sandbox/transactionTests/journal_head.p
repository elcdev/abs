USING modules.transaction.*.
USING sandbox.transactionTests.*.

DEFINE VARIABLE key  AS INT64   FORMAT "9"      INITIAL 0.
DEFINE VARIABLE ques AS LOGICAL FORMAT "Yes/No" INITIAL YES.

{journal_forms.i}

REPEAT WHILE key = 0 ON ENDKEY UNDO, RETURN:
    showHeaderForm().   
    showBalancesForm().

    MESSAGE "1-New, 2-Old, 3-Exit" UPDATE key.

    IF key = 1 
    THEN DO:
        MESSAGE "Create new ?" UPDATE ques.
        IF ques 
        THEN DO:
            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Creating new transaction...".
        END.
    END.
    
    IF key = 1 AND ques OR key = 2 
    THEN DO:
        DO ON ERROR UNDO, THROW:
            clearAllForms().
            run ./trx_entry.p(key).
            
            CATCH eAnyError AS Progress.Lang.Error:
                MESSAGE eAnyError:GetMessage(1).
                PAUSE 5.
            END CATCH.
        END.
        key = 0.
    END.
END.
