input from sysc.d.
repeat while true:
	create sysc.
	import sysc.
end.
input close.

for each sysc where sysc.sysc = "":
		delete sysc.
end.		