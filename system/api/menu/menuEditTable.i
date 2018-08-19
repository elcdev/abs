DEFINE TEMP-TABLE formEditTable NO-UNDO 
    FIELD id            AS INT64 
    FIELD fieldName     AS CHARACTER
    FIELD fieldValue    AS CHARACTER 
    FIELD fieldLabel    AS CHARACTER 
    FIELD fieldPosition AS INTEGER
    FIELD fieldType     AS CHARACTER
    
    INDEX pk id fieldPosition
    INDEX fieldName fieldName
    INDEX fieldValue fieldValue
    .