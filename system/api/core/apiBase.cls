USING abs.system.core.*.

CLASS apiBase IMPLEMENTS apiInterface:
     DEFINE PUBLIC VARIABLE response AS CLASS responseBase.
     DEFINE PUBLIC VARIABLE garbage  AS CLASS garbageCollectorType.
     
     CONSTRUCTOR apiBase():
        response = NEW responseBase().
        garbage  = NEW garbageCollectorType().
     END.
     
     DESTRUCTOR apiBase():
        DELETE OBJECT response NO-ERROR.
        DELETE OBJECT garbage  NO-ERROR.
     END.
     
     METHOD PUBLIC responseBase invoke(request AS requestBase).
        RETURN response.
     END.
END CLASS.