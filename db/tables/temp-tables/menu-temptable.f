/*
DEF TEMP-TABLE menu NO-UNDO
        FIELD id                AS INT64
        FIELD version           AS INT64
        FIELD state             AS INT64
        FIELD modify_date       AS DATETIME
        FIELD create_date       AS DATETIME
        FIELD modify_user       AS CHAR
        FIELD create_user       AS CHAR

        FIELD position          AS INT
        FIELD functionName      AS CHAR
        FIELD procedureName     AS CHAR
        FIELD slug              AS CHAR
        FIELD description       AS CHAR
        
        INDEX id id
        INDEX version version
        INDEX state state
        INDEX account_id account_id
        INDEX name name 
        INDEX modify_date modify_date
        INDEX is_active is_active
    .
*/


