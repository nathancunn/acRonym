#' Get acronyms from given text
#'
#' Creates a tibble with a list of acronyms defined in `str` along with a guess at their
#' definition. Acronyms are defined as occurring within parentheses
#' @param str A string containing the acronyms.
#' @return A tibble with columns "Acronym" and "Definition"
#' @examples
#' readLines(file) %>%
#' get_acronyms
#' @import dplyr
#' @import tibble
#' @import stringr
#' @importFrom purrr map
#' @importFrom tidyr unnest
#' @export
get_acronyms <- function(str) {
  tryCatch(expr = {
    # Collapse input vector into a single string for simplicity
    full_text <- paste(str, collapse = " . ")

    # Split the text by the opening parenthesis of a potential acronym
    parts <- stringr::str_split(full_text, " \\(")[[1]]

    # If there's only one part, no acronyms were found
    if (length(parts) <= 1) {
      return(tibble::tibble("Acronym" = character(), "Definition" = character()))
    }

    # The text before each split is a potential definition
    definitions_raw <- parts[1:(length(parts) - 1)]
    # The text after each split contains the acronym
    acronym_parts <- parts[2:length(parts)]

    # Extract the acronym itself, which is at the start of the part, ending with a ')'
    acronyms_raw <- stringr::str_extract(acronym_parts, "^[A-Z]{2,}\\)")

    # Filter out parts that didn't contain a valid acronym (e.g., just an opening parenthesis)
    valid_indices <- !is.na(acronyms_raw)
    if (!any(valid_indices)) {
      return(tibble::tibble("Acronym" = character(), "Definition" = character()))
    }
    acronyms <- stringr::str_sub(acronyms_raw[valid_indices], end = -2)
    definitions_raw <- definitions_raw[valid_indices]

    # For each raw definition, extract the correct number of words based on acronym length
    definitions <- purrr::map2_chr(definitions_raw, nchar(acronyms), function(def_raw, n) {
      # Handle special words like 'the', 'of', 'with' by temporarily replacing them
      # so they aren't counted as separate words by `word()`
      temp_text <- stringr::str_replace_all(def_raw, " (the|of|with)", "%%%\\1")
      # Clean up other characters that might interfere with word separation
      temp_text <- stringr::str_replace_all(temp_text, "---|\\{|\\}|-", " ")

      # Extract the last N words
      def <- stringr::word(temp_text, start = -n, end = -1)
      # Restore the special words
      def <- stringr::str_replace_all(def, "%%%", " ")
      # Title case the definition
      stringr::str_to_title(def)
    })

    # Create the final tibble and remove duplicate acronyms, keeping the first occurrence
    tibble::tibble(Acronym = acronyms, Definition = definitions) %>%
      dplyr::distinct(Acronym, .keep_all = TRUE)

  }, error = function(e) {
    # In case of any error, return an empty tibble as the original function did
    tibble::tibble("Acronym" = character(), "Definition" = character())
  })
}

#' Get acronyms from all files in a directory
#'
#' Runs \code{get_acronyms} recursively over all specified files in a directory.
#' @param path The root folder containing the relevant files
#' @param extension The file extension, defaults to "tex"
#' @return A tibble containing columns "Acronym" and "Definition"
#' @import dplyr
#' @import tibble
#' @import stringr
#' @export
get_acronyms_dir <- function(path, extension = "tex") {
  all_files <- list.files(path, pattern = paste("\\.", extension, "$", sep = ""),
                          recursive = TRUE, full.names = TRUE)
  out <- tibble("Acronym" = character(), "Definition" = character())
  for(file in all_files) {
    out <- readLines(file) %>%
      get_acronyms() %>%
      full_join(out, by = c("Acronym", "Definition"))
  }
  out %>% group_by(Acronym) %>%
    slice(1) %>%
    ungroup() %>%
    return
}
