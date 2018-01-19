# Tested and verified in gawk.

BEGIN {
  # Collect a history of N samples to calculate stats.
  HISTSIZE = 180
}

# If a timestamp line is provided, collect it here. It should be
# provided each time a sample is taken. (See example invocation)
/^ts / { ts = $2 }

function collect(name, fvalues, type) {

  # If there is a previous sample (i.e. not the first time polling),
  # then take the difference for each type of work. Append each of
  # these to the samples taken for the current sampling period.
  #
  # Because counters increment every hundredth of a second, we may
  # see more than one hundred samples in some loops depending on
  # system load and other factors. This data is capped to prevent
  # numbers greater than 100 appearing.

  if (count[name] > 0) {

    for (fname in fvalues) {

      switch (type) {

        case "counter":
          fv = min(fvalues[fname] - prev[name, fname], 100)
          break

        case "gauge":
          fv = fvalues[fname]
          break
      }

      hist[name, fname][length(hist[name, fname]) + 1] = fv
    }
  }

  count[name]++
}

function summary(name, fvalues) {

  # If this is the Nth sample where N is our desired number of samples,
  # then compute overall stats for the current period. Print these and
  # wipe out the collected samples, starting over again.

  if (count[name] > 0 && count[name] % HISTSIZE == 0) {

    printf "name=%s c=%s slen=%s ", name, count[name], HISTSIZE

    if (typeof(ts) != "untyped") {
      printf "ts=%s ", ts
    }

    for (fname in fvalues) {
      asort(hist[name, fname])

      printf "%s20=%-3s %s50=%-3s %s90=%-3s %smax=%-3s ",
             fname, p(20,  hist[name, fname]),
             fname, p(50,  hist[name, fname]),
             fname, p(90,  hist[name, fname]),
             fname, p(100, hist[name, fname])

      delete hist[name, fname]
    }

    printf "\n"

  }

  for (fname in fvalues) {
    prev[name, fname] = fvalues[fname]
  }

  delete fvalues
}

function min(a,b) {
  return a < b ? a : b
}

# nearest-rank percentile, assumes sorted array
function p(k, values) {
  return values[ceilpos((k / 100) * length(values))]
}

# ceil; only for positive ints
function ceilpos(n) {
  return n == int(n) ? n : int(n) + 1
}

