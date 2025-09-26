# Deprecated
library(dplyr)
library(tidyr)



cross_tab <- function(data, var_row, var_col, fatal_col = FALSE, show_percentage = TRUE) {
    # Cria coluna 'fatalidade' se necessário
    if (fatal_col) {
        data <- data %>%
            mutate(fatalidade = ifelse(mortos > 0, "Sim", "Não"))
        col_for_calc <- "fatalidade"
    } else {
        col_for_calc <- var_col
    }

    if (fatal_col) {
        result <- data %>%
            group_by(.data[[var_row]], .data[[col_for_calc]]) %>%
            summarise(
                total = n(),
                fatais = sum(.data[[col_for_calc]] == "Sim", na.rm = TRUE),
                perc_fatais = round(100 * fatais / total, 2),
                .groups = "drop"
            ) %>%
            arrange(desc(perc_fatais))
    } else {
        result <- data %>%
            group_by(.data[[var_row]], .data[[col_for_calc]]) %>%
            summarise(contagem = n(), .groups = "drop") %>%
            pivot_wider(names_from = col_for_calc, values_from = contagem, values_fill = 0)

        if (show_percentage) {
            perc_cols <- setdiff(names(result), var_row)
            result <- result %>%
                rowwise() %>%
                mutate(across(all_of(perc_cols), ~ paste0(.x, " (", round(100 * .x / sum(c_across(all_of(perc_cols))), 2), "%)"))) %>%
                ungroup()
        }
    }

    return(result)
}
