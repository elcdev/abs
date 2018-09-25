class system.api.stomp.Logger:

    /*
    A very basic logging class, writes output to a file
    */

    def private stream s-log.
    def private variable l-filename as char no-undo.

    constructor public Logger(
        input i-filename as char
        ):
        l-filename = subst("&1/&2&3&4", 
            session:temp-directory, 
            i-filename,
            entry(1, replace(replace(replace(iso-date(now), "-", ""), ":", ""), "T", ""), "."),
            ".log").
        openstream().
    end constructor.

    destructor public Logger():
        closestream().
    end destructor.

    method private void openstream():
        output stream s-log to value(l-filename).
    end method.

    method private void closestream():
        output stream s-log close.
    end method.

    method public void writeMessage(
        input iSeverity as integer,
        input iMessage as character
        ):

        /* if the stream is closed re-open it */
        if seek(s-log) = ? then openstream().
        put stream s-log unformatted iso-date(now) " " iSeverity " " iMessage skip.
    end.

end class.
