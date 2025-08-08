context("get_acronyms")

test_that("get_acronyms extracts a single acronym", {
  text <- "This is a test for the Three Letter Acronym (TLA)."
  acronyms <- get_acronyms(text)
  expect_equal(nrow(acronyms), 1)
  expect_equal(acronyms$Acronym, "TLA")
  expect_equal(acronyms$Definition, "Three Letter Acronym")
})

test_that("get_acronyms extracts multiple acronyms", {
  text <- "This is a test for the Three Letter Acronym (TLA) and the Four Letter Word (FLW)."
  acronyms <- get_acronyms(text)
  expect_equal(nrow(acronyms), 2)
  expect_equal(acronyms$Acronym, c("TLA", "FLW"))
  expect_equal(acronyms$Definition, c("Three Letter Acronym", "Four Letter Word"))
})

test_that("get_acronyms handles ignored words", {
  text <- "United States of America (USA)"
  acronyms <- get_acronyms(text)
  expect_equal(nrow(acronyms), 1)
  expect_equal(acronyms$Acronym, "USA")
  expect_equal(acronyms$Definition, "United States Of America")
})

test_that("get_acronyms handles no acronyms", {
  text <- "This text has no acronyms."
  acronyms <- get_acronyms(text)
  expect_equal(nrow(acronyms), 0)
})

test_that("get_acronyms handles empty string", {
  text <- ""
  acronyms <- get_acronyms(text)
  expect_equal(nrow(acronyms), 0)
})
