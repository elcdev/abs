CLASS menuApi INHERITS apiBase:

     METHOD PUBLIC OVERRIDE responseBase invoke(request AS requestBase).
        DEFINE VARIABLE tResponseBase AS responseBase.
        
        tResponseBase = NEW responseBase().
        
        RETURN tResponseBase.
     END.

END CLASS.