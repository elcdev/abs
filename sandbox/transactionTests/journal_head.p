USING modules.transaction.*.
USING sandbox.transactionTests.*.

DEFINE VARIABLE chooseNewOld  AS INT64   FORMAT "9"      INITIAL 0.
DEFINE VARIABLE ques          AS LOGICAL FORMAT "Yes/No" INITIAL YES.

{sandbox/transactionTests/journal_forms.i}

REPEAT WHILE chooseNewOld = 0 ON ENDKEY UNDO, RETURN:
    showHeaderForm().   
    showBalancesForm().

    MESSAGE "1-New, 2-Old, 3-Exit" UPDATE chooseNewOld.

    IF chooseNewOld = 1 
    THEN DO:
        MESSAGE "Create new ?" UPDATE ques.
        IF ques 
        THEN DO:
            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Creating new transaction...".
        END.
    END.
    
    IF chooseNewOld = 1 AND ques OR chooseNewOld = 2 
    THEN DO:
        DO ON ERROR UNDO, THROW:
            clearAllForms().
            run sandbox/transactionTests/journal_entry.p(chooseNewOld).
            
            CATCH eAnyError AS Progress.Lang.Error:
                MESSAGE eAnyError:GetMessage(1).
                PAUSE 5.
            END CATCH.
        END.
        chooseNewOld = 0.
    END.
END.
