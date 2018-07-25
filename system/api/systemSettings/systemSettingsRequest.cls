CLASS systemSettingsRequest inherits requestBase IMPLEMENTS dbInterface:
    DEF VAR parent_id   AS CHARACTER NO-UNDO.
	DEF VAR field_name  AS CHARACTER NO-UNDO.
	DEF VAR field_value AS CHARACTER NO-UNDO.

	METHOD PUBLIC CHARACTER putDb():
        {requestItemPutDb.f system_settings}
        
        parent_id   = system_settings.parent_id.
        field_name  = system_settings.field_name.
        field_value = system_settings.field_value.
        
        RETURN "".
	END.
	
	METHOD PUBLIC CHARACTER getDb(iId AS INT):
        {requestItemGetDb.f system_settings}
        
        parent_id   = system_settings.parent_id.
        field_name  = system_settings.field_name.
        field_value = system_settings.field_value.
        
        RETURN "".
	END.
	
	METHOD PUBLIC CHARACTER getJson():
	
	END.
	
END CLASS.