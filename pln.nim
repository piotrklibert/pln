#
# PLNizator
#
# Displays an amount of PLN you'd get for given amount of USD. Accepts input via
# command line argument. Without providing a value it defaults to 1.
#
# TODO:
# 1* cache - the API is updated once an hour, but is limited to 1k requests per
# month.
#
import os
import json
import times
import strutils
import httpclient

const CACHE_FNAME = ".plnizator"


proc getDay(t : Time) : range[0..365] =
    return getLocalTime(t).yearday


################################################################################
# API
################################################################################

const key : string = slurp("key.txt").strip()

proc get_url() : string =
  return "http://openexchangerates.org/api/latest.json?app_id=" & key


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
################################################################################

proc read_cache(fname : string) : float =
    echo "Reading from cache..."
    let cached_val = readFile(fname)
    return cached_val.parseFloat


proc fetch_save(fname : string) : float =
    let file = open(fname, fmWrite)
    file.write($(get_rate()))
    file.close()
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

var usd : float = 1.0
if paramCount() > 0:
    usd = parseFloat(paramStr(1))

let val = usd * getRateCache()

echo("$", $usd, " ==> ", formatFloat(val, ffDecimal, 3), "PLN")
