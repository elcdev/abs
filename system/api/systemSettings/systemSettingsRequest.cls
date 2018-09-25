USING system.api.core.*.
USING system.api.systemSettings.*.

CLASS system.api.systemSettings.systemSettingsRequest inherits requestBase IMPLEMENTS dbInterface:
    DEF VAR parent_id   AS INT64 NO-UNDO.
	DEF VAR field_name  AS CHARACTER NO-UNDO.
	DEF VAR field_value AS CHARACTER NO-UNDO.

    /*{dbModelJsonParser.f &class="system.api.systemSettings.systemSettingsRequest"}*/
    
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="system_settings"}
        
        parent_id   = system_settings.parent_id.
        field_name  = system_settings.field_name.
        field_value = system_settings.field_value.
        
        RETURN "".
	END.
	
    METHOD PUBLIC OVERRIDE CHARACTER getDb():
    
    END.
    
	METHOD PUBLIC CHARACTER getDb(iId AS INT64):
        {requestItemGetDb.f &TABLE="system_settings" &field="id"}
        
        parent_id   = system_settings.parent_id.
        field_name  = system_settings.field_name.
        field_value = system_settings.field_value.
        
        RETURN "".
	END.
	
	METHOD PUBLIC OVERRIDE CHARACTER getJson():
	
	END.
	
END CLASS.