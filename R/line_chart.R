#' Create a Horizontal Line Chart for Categories
#'
#' This function creates a horizontal line chart showing all categories
#' and their corresponding values across multiple data columns. Each category is represented
#' by a line connecting its values across the specified data columns.
#'
#' @param data A query object created by query()
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' # Create sample data
#' sample_data <- tibble::tibble(
#'   Category = c("A", "B", "C"),
#'   Period1 = c(10, 20, 30),
#'   Period2 = c(15, 25, 35)
#' )
#' # Create a query and visualize
#' q <- query(sample_data, "Category", c("Period1", "Period2"))
#' line_chart(q)
#'
line_chart <- function(data) {
  if (!inherits(data, "query")) {
    stop("Data must be a query object created by query()")
  }

  # Extract components
  df <- data$data
  category_col <- rlang::sym(data$category_col)
  data_cols <- data$data_cols

  # Filter and prepare data for plotting
  plot_data <- df |>
    # Remove rows with NA values
    dplyr::filter(!any(is.na(dplyr::pick(dplyr::all_of(data_cols))))) |>
    # Reshape data for plotting
    tidyr::pivot_longer(
      cols = dplyr::all_of(data_cols),
      names_to = "x_value",
      values_to = "y_value"
    )

  # Convert x_value to a factor to maintain order
  plot_data$x_value <- factor(plot_data$x_value, levels = data_cols)

  # Create the plot
  ggplot2::ggplot(plot_data,
                  ggplot2::aes(x = x_value,
             y = y_value,
             color = !!category_col,
             group = !!category_col)) +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      x = "X Axis",
      y = "Y Axis",
      color = "Category"
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      legend.position = "right"
    )
}