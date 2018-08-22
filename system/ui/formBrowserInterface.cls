INTERFACE formBrowserInterface:
    METHOD PUBLIC CHARACTER InitForm().
    METHOD PUBLIC CHARACTER Recodset().
   /* METHOD PUBLIC CHARACTER SearchByKeyword(searchKeyword AS CHAR, TABLE searchBuffer AS HANDLE).*/
    
    METHOD PUBLIC CHARACTER RepositionBrowse().
    METHOD PUBLIC CHARACTER DisableForm().
    METHOD PUBLIC CHARACTER ShowForm().
END.