INTERFACE formBrowserInterface:

    METHOD PUBLIC CHARACTER InitForm().
    METHOD PUBLIC CHARACTER Recodset().
    METHOD PUBLIC INT64 SearchByKeyword(searchKeyword AS CHAR, searchBuffer AS BUFFER).
    METHOD PUBLIC INT64 RepositionBrowse().
    METHOD PUBLIC INT64 DisableForm().
    METHOD PUBLIC INT64 ShowForm().

END.