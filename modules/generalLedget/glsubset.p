/*
 G/L account entry
*/
{prg_head.f} /* {mainhead.i GLFILE} */
DEFINE VARIABLE id AS INT64.

{main.i
 &option    = "GL"
 &head      = "gl"
 &headkey   = "gl"
 &framename = "gl"
 &formname  = "gl"
 &findcon   = "true"
 &addcon    = "true"
 &start     = " "
 &clearframe = " "
 &viewframe  = " "
 &prefind    = " "
 &postfind   = " "
 &numprg     = "prompt"
 &preadd     = " find last gl use-index id no-lock no-error. 
 if available gl then id = gl.id + 1 . else id = 1. "
 &postadd    = " "
 &subprg     = "glsetsub" 
 &end        = " "
}
