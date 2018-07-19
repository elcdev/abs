CLASS api INHERITS webApiType IMPLEMENTS webApiInterface:

    METHOD PUBLIC OVERRIDE responseType Invoke(iRequest AS requestType):
        /* TODO */
		CASE iRequest:api + "." + iRequest:name + "." + iRequest:action:
			WHEN "api.systemsettings.getjson" THEN tDataApi = NEW systemSettings(iRequest).
			WHEN "api.systemsettings.putdb"   THEN tDataApi = NEW systemSettings(iRequest).
			WHEN "api.systemsettings.getdb"   THEN tDataApi = NEW systemSettings(iRequest).
		END.

		RETURN super:invoke(iRequest).
    END.

END.