    DEFINE PUBLIC PROPERTY {&name} AS {&type} NO-UNDO
        PUBLIC GET():
            RETURN {&field}.
        END GET.
        PUBLIC SET(iValue AS {&type}):
             {&field} = iValue.
        END SET.
