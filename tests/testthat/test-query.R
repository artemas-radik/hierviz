test_that("query creates valid query object", {
  data <- tibble::tibble(
    Category = c("A", "B", "C"),
    Val1 = c(1, 2, 3),
    Val2 = c(4, 5, 6)
  )
  
  q <- query(data, "Category", c("Val1", "Val2"))
  
  expect_s3_class(q, "query")
  expect_equal(q$category_col, "Category")
  expect_equal(q$data_cols, c("Val1", "Val2"))
  expect_equal(q$data, data)
})

test_that("query uses defaults correctly", {
  data <- tibble::tibble(
    Category = c("A", "B"),
    Val1 = c(1, 2),
    Val2 = c(3, 4)
  )
  
  # Test default category column (first column)
  q1 <- query(data)
  expect_equal(q1$category_col, "Category")
  expect_equal(q1$data_cols, c("Val1", "Val2"))
  
  # Test default data columns (all except category)
  q2 <- query(data, "Category")
  expect_equal(q2$data_cols, c("Val1", "Val2"))
})

test_that("query validates numeric data columns", {
  data <- tibble::tibble(
    Category = c("A", "B"),
    Val1 = c(1, 2),
    Text = c("x", "y")
  )
  
  expect_error(
    query(data, "Category", c("Val1", "Text")),
    "Column 'Text' must contain numeric values"
  )
})

test_that("query detects duplicate categories", {
  data <- tibble::tibble(
    Category = c("A", "A", "B"),
    Val1 = c(1, 2, 3)
  )
  
  expect_error(
    query(data, "Category"),
    "Duplicate categories detected"
  )
})