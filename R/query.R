#' Create a Query for Analysis
#'
#' This function creates a query object that specifies what data should be analyzed
#' and how. It validates the query parameters and creates a structured object that can
#' be used with visualization functions like line_chart() and change_table().
#'
#' @param data A data frame or tibble containing the dataset to analyze.
#' @param category_col Name of the category column as a string. Defaults to first column.
#' @param data_cols A character vector of column names containing the numeric data to analyze.
#'   Defaults to all remaining columns.
#'
#' @return A list with class "query" containing:
#'   \item{data}{The original data frame}
#'   \item{category_col}{The name of the category column}
#'   \item{data_cols}{The names of the data columns}
#' @importFrom rlang .data
#' @importFrom dplyr n
#' @export
#'
#' @examples
#' # Create sample data
#' sample_data <- tibble::tibble(
#'   Category = c("A", "B", "C"),
#'   Period1 = c(10, 20, 30),
#'   Period2 = c(15, 25, 35)
#' )
#' 
#' # Create a query object with defaults
#' q1 <- query(sample_data)  # Uses first column as category, rest as data
#' 
#' # Create a query object with specific columns
#' q2 <- query(sample_data, "Category", c("Period1", "Period2"))
#' 
#' # Use with visualization functions
#' line_chart(q1)  # or line_chart(q2)
#'
query <- function(data, category_col = NULL, data_cols = NULL) {
  # Set defaults if not provided
  if (is.null(category_col)) {
    category_col <- names(data)[1]
  }
  
  if (is.null(data_cols)) {
    # Use all columns except the category column
    data_cols <- setdiff(names(data), category_col)
  }
  
  # Verify category_col exists
  if (!category_col %in% names(data)) {
    stop(sprintf("Category column '%s' not found in data", category_col))
  }
  
  # Check for duplicates in category_col
  duplicates <- data |>
    dplyr::count(.data[[category_col]]) |>
    dplyr::filter(n > 1)

  if (nrow(duplicates) > 0) {
    dup_cats <- paste(duplicates[[1]], collapse = ", ")
    stop(sprintf("Duplicate categories detected: %s", dup_cats))
  }

  # Check for NA values in category_col
  if (any(is.na(data[[category_col]]))) {
    stop("NA values found in category column")
  }

  # Validate numeric data
  for (col in data_cols) {
    if (!is.numeric(data[[col]])) {
      stop(sprintf("Column '%s' must contain numeric values", col))
    }
  }
  
  # Create and return the query structure
  q <- list(
    data = data,
    category_col = category_col,
    data_cols = data_cols
  )
  
  class(q) <- "query"
  return(q)
} 