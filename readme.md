## plnizator - a cmd-line tool for currency conversions

Currently it only converts between PLN and USD, hence the name.

To build, you need to obtain the key from http://openexchangerates.org and put
it in the `key.txt` in current directory, and compile:

    $ echo <your_key> >key.txt
    $ nim c pln.nim

Running the program:

    $ pln 2
    Fetching from API...
    Reading from cache...
    $2.0 ==> 7.900PLN

    $
