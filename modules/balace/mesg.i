/* mesg.i
   accepts 1 input argument
*/
find first msg where (msg.lang eq g-lang) and msg.ln eq {1} no-lock no-error.
message "[MSG#{1}]" (if available msg then msg.msg else "No message in bank.msg") 
