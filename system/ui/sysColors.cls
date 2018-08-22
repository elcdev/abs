CLASS sysColors:

    METHOD PUBLIC INT64 getColorNumber(iColor AS CHAR):
        CASE iColor:
            WHEN "RED/BLACK"        THEN RETURN 5.
            WHEN "GREEN/BLACK"      THEN RETURN 6. 
            WHEN "YELLOW/BLACK"     THEN RETURN 7.
            WHEN "BLUE/BLACK"       THEN RETURN 8.
            WHEN "MAGENTA/BLACK"    THEN RETURN 9.
            WHEN "CYAN/BLACK"       THEN RETURN 10.
            WHEN "WHITE/BLACK"      THEN RETURN 11.
            
            WHEN "RED/BLUE"         THEN RETURN 12.
            WHEN "RED/GREEN"        THEN RETURN 13.
            WHEN "RED/YELLOW"       THEN RETURN 14.
            WHEN "RED/MAGENTA"      THEN RETURN 15.
            WHEN "RED/CYAN"         THEN RETURN 16.
            WHEN "RED/WHITE"        THEN RETURN 17.

            WHEN "GREEN/BLUE"       THEN RETURN 18.
            WHEN "GREEN/RED"        THEN RETURN 19.
            WHEN "GREEN/YELLOW"     THEN RETURN 20.
            WHEN "GREEN/MAGENTA"    THEN RETURN 21.
            WHEN "GREEN/CYAN"       THEN RETURN 22.
            WHEN "GREEN/WHITE"      THEN RETURN 23.
   
            WHEN "YELLOW/BLUE"      THEN RETURN 24.
            WHEN "YELLOW/RED"       THEN RETURN 25.
            WHEN "YELLOW/GREEN"     THEN RETURN 26.
            WHEN "YELLOW/MAGENTA"   THEN RETURN 27.
            WHEN "YELLOW/CYAN"      THEN RETURN 28.
            WHEN "YELLOW/WHITE"     THEN RETURN 29.
        
            WHEN "BLUE/YELLOW"      THEN RETURN 30.
            WHEN "BLUE/RED"         THEN RETURN 31.
            WHEN "BLUE/GREEN"       THEN RETURN 32.
            WHEN "BLUE/MAGENTA"     THEN RETURN 33.
            WHEN "BLUE/CYAN"        THEN RETURN 34.
            WHEN "BLUE/WHITE"       THEN RETURN 35.
        
            WHEN "MAGENTA/YELLOW"      THEN RETURN 36.
            WHEN "MAGENTA/RED"         THEN RETURN 37.
            WHEN "MAGENTA/GREEN"       THEN RETURN 38.
            WHEN "MAGENTA/BLUE"        THEN RETURN 39.
            WHEN "MAGENTA/CYAN"        THEN RETURN 40.
            WHEN "MAGENTA/WHITE"       THEN RETURN 41.

            WHEN "CYAN/YELLOW"         THEN RETURN 42.
            WHEN "CYAN/RED"            THEN RETURN 43.
            WHEN "CYAN/GREEN"          THEN RETURN 44.
            WHEN "CYAN/BLUE"           THEN RETURN 45.
            WHEN "CYAN/MAGENTA"        THEN RETURN 46.
            WHEN "CYAN/WHITE"          THEN RETURN 47.

            WHEN "WHITE/YELLOW"        THEN RETURN 48.
            WHEN "WHITE/RED"           THEN RETURN 49.
            WHEN "WHITE/GREEN"         THEN RETURN 50.
            WHEN "WHITE/BLUE"          THEN RETURN 51.
            WHEN "WHITE/MAGENTA"       THEN RETURN 52.
            WHEN "WHITE/CYAN"          THEN RETURN 53.

            WHEN "BLACK/YELLOW"        THEN RETURN 54.
            WHEN "BLACK/RED"           THEN RETURN 55.
            WHEN "BLACK/GREEN"         THEN RETURN 56.
            WHEN "BLACK/BLUE"          THEN RETURN 57.
            WHEN "BLACK/MAGENTA"       THEN RETURN 58.
            WHEN "BLACK/CYAN"          THEN RETURN 59.
            WHEN "BLACK/WHITE"         THEN RETURN 60.
            
            WHEN "GREEN/DKBL"          THEN RETURN 61.
            WHEN "BROWN/WHITE"         THEN RETURN 62.
            WHEN "BROWN/CYAN"          THEN RETURN 63.
            WHEN "DKRD/BLACK"          THEN RETURN 66.
            WHEN "CYAN/PURPLE"         THEN RETURN 68.
            WHEN "BLACK/PURPLE"        THEN RETURN 69.
            WHEN "WHITE/PURPLE"        THEN RETURN 70.

            WHEN "ORANGE/PURPLE"       THEN RETURN 71.
            WHEN "GREEN/PURPLE"        THEN RETURN 72.
            WHEN "BLINKRED"            THEN RETURN 73.
            WHEN "ORANGE/BLACK"        THEN RETURN 74.
            WHEN "CYAN/FOREST"         THEN RETURN 75.
            WHEN "ORANGE/FOREST"       THEN RETURN 76.
            WHEN "WHITE/FOREST"        THEN RETURN 77.
            
            WHEN "GREEN/FOREST"        THEN RETURN 78.
            WHEN "BLACK/FOREST"        THEN RETURN 79.
            WHEN "LTGR/FOREST"         THEN RETURN 80.
        END CASE.
        
        RETURN 0. /* TODO! */
    END.


END.