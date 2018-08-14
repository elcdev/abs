INTERFACE formBrowserInterface:
    METHOD PUBLIC CHARACTER InitForm().
    METHOD PUBLIC CHARACTER Recodset().
    METHOD PUBLIC CHARACTER SearchByKeyword(searchKeyword AS CHAR, TEMP-TABLE searchBuffer AS HANDLE).
    METHOD PUBLIC INT64 RepositionBrowse().
    METHOD PUBLIC INT64 DisableForm().
    METHOD PUBLIC INT64 ShowForm().
END.