TRIGGER PROCEDURE FOR REPLICATION-WRITE OF {&table}.

IF {&table}.id = 0 THEN
 DO:
	{&table}.id = NEXT-VALUE({&sequence_id}).
	{&table}.create_user = globalSettings:user.
	{&table}.create_date = now.
 END.

{&table}.version = next-value(version_id).
{&table}.modify_user = globalSettings:user.
{&table}.modify_date = now.
 
