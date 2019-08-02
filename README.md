# acRonym
This is an R package for extracting acronyms defined within a body of text. It
assumes that acronyms are defined in the format: Three Letter Acronym (TLA) and also
that you only define one acronym per sentence.

# Installation
``` r
devtools::install_github("https://github.com/nathancunn/acRonym")
```


# Basic use
```r
get_acronyms("Three letter acronym (TLA). Or Three letter initialism (TLI)")
```
Gives:

| Acronym | Definition              |
|---------|-------------------------|
| TLA     | Three Letter Acronym    |
| TLI     | Three Letter Initialism |

To get the acronyms from a single file

``` r
readLines(file) %>%
  get_acronyms
```

To get the acronyms from all files within a directory

``` r
get_acronyms_dir(path, extension = "tex")
```
