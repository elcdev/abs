DEF VAR core      AS systemCore NO-UNDO.
DEF VAR api       AS webApiType   NO-UNDO.

core    = NEW systemCore().

IF (NOT core:cSession:isLoggedIn) AND (core:request:api <> "forms" OR core:request:name <> "signin") THEN
 DO:
    core:request:parseSlug("/forms/signin/").
 END.

CASE core:request:api:
    WHEN "forms" THEN api = NEW webFormsApi().
    WHEN "pages" THEN api = NEW webPagesApi().
    WHEN "api"   THEN api = NEW webFormsApi(). /* TODO */
END.

core:response = api:invoke(core:request).

core:getHtml(core:request, core:response).

core:cSession:saveSession().

DELETE OBJECT core NO-ERROR.
