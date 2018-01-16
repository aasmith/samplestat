@include "stats"

/^cpu[0-9]+/ { # cpu0 123 56 ...
  cpu = $1

  # See https://www.kernel.org/doc/Documentation/filesystems/proc.txt
  # for field definitions

  f["user"] = $2
  f["nice"] = $3
  f["syst"] = $4
  f["idle"] = $5
  f["intr"] = $7
  f["soft"] = $8
  f["stea"] = $9

  collect($1, f, "counter")
  summary($1, f)
}

/^procs_running/ {
  f["prun"] = $2

  collect($1, f, "value")
  summary($1, f)
}

/^procs_blocked/ {
  f["pblk"] = $2

  collect($1, f, "value")
  summary($1, f)
}

/^processes/ {
  f["procs"] = $2

  collect($1, f, "counter")
  summary($1, f)
}

