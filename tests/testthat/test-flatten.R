test_that("flatten handles basic hierarchical data correctly", {
  data <- tibble::tibble(
    Category = c("Section1:", "item1", "item2", "Section2:", "item3", "item4")
  )
  
  result <- flatten(data)
  
  expect_equal(nrow(result), 4)  # Should remove header rows
  expect_equal(
    result$Category,
    c("Section1: item1", "Section1: item2", "Section2: item3", "Section2: item4")
  )
})

test_that("flatten works with specified column name", {
  data <- tibble::tibble(
    OtherCol = 1:6,
    MyCategory = c("Section1:", "item1", "item2", "Section2:", "item3", "item4")
  )
  
  result <- flatten(data, "MyCategory")
  
  expect_equal(nrow(result), 4)
  expect_equal(
    result$MyCategory,
    c("Section1: item1", "Section1: item2", "Section2: item3", "Section2: item4")
  )
})

test_that("flatten allows duplicate items under different sections", {
  data <- tibble::tibble(
    Category = c("Section1:", "item1", "item2", "Section2:", "item1", "item3")
  )
  
  result <- flatten(data)
  
  expect_equal(nrow(result), 4)
  expect_equal(
    result$Category,
    c("Section1: item1", "Section1: item2", "Section2: item1", "Section2: item3")
  )
})

test_that("flatten detects duplicate flattened categories", {
  data <- tibble::tibble(
    Category = c("Section1:", "item1", "item2", "Section1:", "item1", "item3")
  )
  
  expect_error(
    flatten(data),
    "Duplicate flattened categories detected"
  )
})

test_that("flatten handles invalid column name", {
  data <- tibble::tibble(Category = c("A", "B"))
  
  expect_error(
    flatten(data, "NonExistentColumn"),
    "Column 'NonExistentColumn' not found in data"
  )
})