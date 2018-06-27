CLASS apiBase IMPLEMENTS apiInterface:
     DEFINE VARIABLE response AS responseBase.
     
     CONSTRUCTOR apiBase():
        response = NEW responseBase().
     END.
     
     DESTRUCTOR apiBase():
        DELETE OBJECT response.
     END.
     
     METHOD PUBLIC responseBase invoke(request AS requestBase).
        RETURN response.
     END.

END CLASS.