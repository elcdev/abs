/* gl.f
*/
form gl.gl          label        "    G/L Account" format "zzzzzzz9"
	 Help "G/L account number" skip
     gl.description label        "    DESCRIPTION" validate(gl.description ne "","Incorrect Description")
	 help "G/L account description" skip
     gl.short_name  label        "     SHORT NAME" validate(gl.short_name ne "","Incorrect Short Description")
	 help "G/L account short description" skip
     gl.gl_type        label     "           TYPE" validate(index("ALORE", gl.gl_type) ne 0,"Incorrect G/L account type")
	 help "A-Assets,L-Lialibities,O-Ownership,R-Revenue,E-Expenes" skip
     gl.subledger_type label     "      SUBLEDGER" validate(gl.subledger_type = "CIF" or gl.subledger_type = "DFB" or
	 gl.subledger_type = "ARP" or gl.subledger_type = "EPS" or gl.subledger_type = "","Incorrect G/L subledger type!") 
	 help "Subledger type: CIF, DFB, ARP, EPS" skip
     gl.total_acc     label       "       IS TOTAL" help "Is G/L account total ?" skip
     gl.parent_gl    label       "  TOTAL ACCOUNT" format "zzzzzzz9"
	 validate(can-find(first gl where gl.gl = gl.parent_gl) = yes or
	 gl.parent_gl = 0,	 "Non-existent G/L Account!") Help "G/L account number" skip
     gl.level        label       "      SUM LEVEL" validate(gl.level > 0 and gl.level < 10,"From 1 to 9") 
	 help "Summizing level: from 1 to 9" skip
     gl.restrict_operation label "RESTRICT MANUAL" help "Restrict manual operation in Journal" skip
     gl.gl_status          label "         STATUS"  validate(gl.gl_status = "ACTIVE" or 
	 gl.gl_status = "CLOSE" ,"Active or Close") help "Active or Close"  skip
     with row 3 side-labels overlay frame gl.
