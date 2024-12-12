test_that("line_chart creates valid ggplot object", {
  data <- tibble::tibble(
    Category = c("A", "B"),
    Val1 = c(1, 2),
    Val2 = c(3, 4)
  )
  
  q <- query(data, "Category", c("Val1", "Val2"))
  plot <- line_chart(q)
  
  expect_s3_class(plot, "ggplot")
})

test_that("line_chart handles NA values correctly", {
  data <- tibble::tibble(
    Category = c("A", "B", "C"),
    Val1 = c(1, NA, 3),
    Val2 = c(4, 5, 6)
  )
  
  q <- query(data, "Category", c("Val1", "Val2"))
  plot <- line_chart(q)
  
  expect_s3_class(plot, "ggplot")
})