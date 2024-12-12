msft <- readxl::read_excel(
  "data-raw/msft-earnings.xlsx",
  sheet = "Quarterly Income Statements",
  skip = 3,
  .name_repair = "minimal"
)

msft <- msft[, c(1, 4:ncol(msft))]
colnames(msft)[1] <- "Category"
usethis::use_data(msft, overwrite = TRUE)
