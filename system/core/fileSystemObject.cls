CLASS fileSystemObject: 

    METHOD PUBLIC CHARACTER FindFile(INPUT-OUTPUT fileNameAndLocation AS CHARACTER ):
        DEFINE VARIABLE tFile AS CHARACTER NO-UNDO.
        tFile = SEARCH(fileNameAndLocation).
        IF tFile = ? THEN RETURN "ERROR-FILE-NOT-FOUND".
        fileNameAndLocation = tFile.
        RETURN "".
    END.
    
END.