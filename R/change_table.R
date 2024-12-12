#' Create a Table with Period-over-Period Changes
#'
#' This function creates a formatted table showing values and their percentage changes
#' between consecutive periods. Positive changes are shown in green, negative in red.
#' Changes are shown immediately after each period. No changes are shown in black.
#'
#' @param data A query object created by query()
#' @importFrom rlang .data :=
#' @export
change_table <- function(data) {
  if (!inherits(data, "query")) {
    stop("Data must be a query object created by query()")
  }

  # Extract components
  df <- data$data
  category_col <- rlang::sym(data$category_col)
  data_cols <- data$data_cols

  if (length(data_cols) < 2) {
    stop("At least 2 data columns are required to calculate changes")
  }

  # Calculate percentage changes
  changes <- df |>
    dplyr::select({{category_col}}, dplyr::all_of(data_cols)) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(data_cols),
        ~ round(.x / 1, 1)  # Round to 1 decimal place
      )
    )
  
  # Create a list to store columns in their final order
  final_cols <- list()
  final_cols[[1]] <- rlang::quo_name(rlang::enquo(category_col))  # Category column first
  
  # Add change columns and reorder columns
  for (i in 1:(length(data_cols)-1)) {
    current_col <- data_cols[i]
    next_col <- data_cols[i+1]
    change_col <- paste0("change_", i)
    
    changes <- changes |>
      dplyr::mutate(
        !!change_col := dplyr::case_when(
          !!rlang::sym(current_col) == 0 & !!rlang::sym(next_col) == 0 ~ 0,
          !!rlang::sym(current_col) == 0 ~ 100,  # From 0 to non-zero is 100% increase
          TRUE ~ (!!rlang::sym(next_col) - !!rlang::sym(current_col)) / 
                 abs(!!rlang::sym(current_col)) * 100
        )
      )
    
    # Add current period and its change column to the final order
    final_cols[[length(final_cols) + 1]] <- current_col
    final_cols[[length(final_cols) + 1]] <- change_col
  }
  
  # Add the last period
  final_cols[[length(final_cols) + 1]] <- data_cols[length(data_cols)]
  
  # Reorder columns
  changes <- changes |>
    dplyr::select(!!!final_cols)
  
  # Get names of all change columns
  change_cols <- paste0("change_", 1:(length(data_cols)-1))

  # Create the table
  gt_table <- gt::gt(changes) |>
    gt::fmt_number(
      columns = dplyr::all_of(data_cols),
      decimals = 1
    )
  
  # Format each change column
  for (i in seq_along(change_cols)) {
    change_col <- change_cols[i]
    period_label <- "% Change"  # ASCII-only label
    
    gt_table <- gt_table |>
      gt::fmt_percent(
        columns = change_col,
        decimals = 1,
        scale_values = FALSE
      ) |>
      gt::cols_label(
        !!change_col := period_label
      ) |>
      gt::tab_style(
        style = gt::cell_text(color = "#28a745"),  # Green
        locations = gt::cells_body(
          columns = change_col,
          rows = .data[[change_col]] > 0
        )
      ) |>
      gt::tab_style(
        style = gt::cell_text(color = "#dc3545"),  # Red
        locations = gt::cells_body(
          columns = change_col,
          rows = .data[[change_col]] < 0
        )
      )
  }
  
  # Final table formatting
  gt_table |>
    gt::tab_options(
      table.font.size = "small",
      data_row.padding = gt::px(2)
    )
} 