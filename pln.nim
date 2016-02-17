#
# PLNizator
#
# Displays an amount of PLN you'd get for given amount of USD. Accepts input via
# command line argument. Without providing a value it defaults to 1.
#

import os
import json
import times
import strutils
import httpclient

const
  CACHE_FNAME = ".plnizator"
  API_KEY = slurp("key.txt").strip()


proc getDay(t : Time) : range[0..365] =
  return getLocalTime(t).yearday


################################################################################
# API
################################################################################

proc get_url() : string =
  return "http://openexchangerates.org/api/latest.json?app_id=" & API_KEY

proc get_rate() : float =
  echo "Fetching from API..."
  var res = get_url().getContent().parseJson()
  res = res["rates"]["PLN"]

  case res.kind
  of JFloat:
    return res.fnum
  else:
    return -1.0


################################################################################
# CACHE
#
# The API is updated once an hour, but is limited to 1k requests per month. I
# don't need to have the absolutely latest exchange rate, so I cache it and only
# refresh the rate once a day.
#
################################################################################

proc read_cache(fname: string) : float = readFile(fname).parseFloat

proc fetch_save(fname: string) : float =
  ## Fetch the current exchange rate from the API and save it in the cache file.
  ## In addition to saving the rate value this function returns it, too.
  writeFile(fname, $get_rate())
  return read_cache(fname)


proc getRateCache() : float =
  let fname = getHomeDir() & CACHE_FNAME

  try:
    let
      mday = getLastModificationTime(fname).getDay
      today = getTime().getDay
    if today - mday > 0:
      return fetch_save(fname)

    return read_cache(fname)

  except IOError, OSError:
    return fetch_save(fname)


################################################################################
# MAIN
################################################################################

when isMainModule:
  var usd : float = 1.0
  if paramCount() > 0:
      usd = paramStr(1).parseFloat()

  let val = usd * getRateCache()
  echo("$", $usd, " ==> ", val.formatFloat(ffDecimal, 3), "PLN")
