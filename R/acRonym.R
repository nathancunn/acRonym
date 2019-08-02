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
    str %>%
      str_split(pattern = "\n") %>%
      str_split(pattern = fixed(".")) %>%
      unlist() %>%
      as_tibble() %>%
      filter(str_detect(value, " \\([A-Z]+\\)")) %>%
      mutate(value = str_replace_all(value, "---|\\{|\\}|-", " "),
             value = str_replace_all(value, " (the|of|with)", "%%%\\1")) %>%
      mutate(Acronym = map(value, function(x) str_extract(x, "\\([^()]+\\)"))) %>%
      unnest() %>%
      mutate(Acronym = str_sub(Acronym, 2, -2)) %>%
      group_by(Acronym) %>%
      slice(1) %>%
      ungroup() %>%
      mutate(num_letters = nchar(Acronym),
             Definition = str_extract(value, ".+ \\("),
             Definition = str_sub(Definition, end = -3),
             Definition = word(Definition, start =  - num_letters, end = -1),
             Definition = str_to_title(Definition),
             Definition = str_replace_all(Definition, "%%%", " ")) %>%
      select(Acronym, Definition)} ,
    error =  function(e) tibble("Acronym" = character(), "Definition" = character()))
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
