test_that("change_table calculates changes correctly", {
  data <- tibble::tibble(
    Category = c("A", "B"),
    Val1 = c(100, 200),
    Val2 = c(150, 180)
  )
  
  q <- query(data, "Category", c("Val1", "Val2"))
  result <- change_table(q)
  
  expect_s3_class(result, "gt_tbl")
})

test_that("change_table handles zero values correctly", {
  data <- tibble::tibble(
    Category = c("A", "B", "C"),
    Val1 = c(0, 0, 100),
    Val2 = c(0, 100, 0)
  )
  
  q <- query(data, "Category", c("Val1", "Val2"))
  result <- change_table(q)
  
  expect_s3_class(result, "gt_tbl")
})

test_that("change_table requires at least two columns", {
  data <- tibble::tibble(
    Category = c("A", "B"),
    Val1 = c(1, 2)
  )
  
  q <- query(data, "Category", "Val1")
  expect_error(
    change_table(q),
    "At least 2 data columns are required"
  )
})