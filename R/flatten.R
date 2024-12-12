#' Flatten Hierarchical Categories with Section Headers
#'
#' This function processes hierarchical data where some rows are section headers
#' (ending with ":") and combines them with their associated categories to create
#' full category names. Header rows are automatically excluded from the output.
#' Items can be duplicated in the input, but the full names must be unique.
#'
#'
#' @param data A data frame or tibble containing the dataset to process.
#' @param category_col Name of the category column as a string. Defaults to first column.
#'
#' @return A tibble with the category column replaced with fully qualified
#'   category names (section: category), with the header rows removed.
#' @importFrom rlang .data :=
#' @importFrom dplyr n
#' @export
#'
#' @examples
#' # Example with duplicate items under different sections
#' data <- tibble::tibble(
#'   Category = c("Section1:", "item1", "item2", "Section2:", "item1", "item3")
#' )
#' flatten(data)  # Uses first column
#' flatten(data, "Category")  # Explicitly specify column
#'
flatten <- function(data, category_col = NULL) {
  # Set default if not provided
  if (is.null(category_col)) {
    category_col <- names(data)[1]
  }

  # Verify category_col exists
  if (!category_col %in% names(data)) {
    stop(sprintf("Column '%s' not found in data", category_col))
  }

  labeled_data <- data |>
    dplyr::mutate(
      section = dplyr::case_when(
        dplyr::lag(.data[[category_col]]) |> stringr::str_ends(":") ~ stringr::str_remove(dplyr::lag(.data[[category_col]]), ":$"),
        TRUE ~ NA_character_
      ),
      section = tidyr::fill(dplyr::tibble(section = section), section, .direction = "down")$section,
      # Replace the original category column
      !!category_col := dplyr::if_else(
        stringr::str_ends(.data[[category_col]], ":"),
        NA_character_,
        paste(section, .data[[category_col]], sep = ": ")
      )
    ) |>
    dplyr::select(-section) |>  # Remove the temporary section column
    # Remove header rows
    dplyr::filter(!is.na(.data[[category_col]]))

  # Check for duplicates in the flattened categories
  duplicates <- labeled_data |>
    dplyr::count(.data[[category_col]]) |>
    dplyr::filter(n > 1)

  if (nrow(duplicates) > 0) {
    dup_cats <- paste(duplicates[[1]], collapse = ", ")
    stop(sprintf("Duplicate flattened categories detected: %s", dup_cats))
  }

  return(labeled_data)
}
