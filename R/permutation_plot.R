
#' Plot Permutation Results
#'
#' @importFrom forcats fct_reorder
#' @importFrom dplyr desc case_when
#' @importFrom ggplot2 ggplot aes geom_pointrange theme_bw geom_hline
#' coord_flip scale_color_manual
#'
#' @param sc_utils_obj sc_utils object
#' @param FDR_threshold FDR value cutoff for significance
#' @param log2FD_threshold Absolute value of log2FD cutoff for significance
#' @param order_clusters Whether to order the clusters by observed log2FD
#'
#' @rdname permutation_plot-function
#'
#' @export

permutation_plot <- function(
	sc_utils_obj,
	FDR_threshold = 0.05,
	log2FD_threshold = log2(1.5),
	order_clusters = TRUE,
	font_size = 16  # Default font size; can be adjusted by the user
) {

	## Retrieve results.
	plot_data <- copy(sc_utils_obj@results$permutation)

	## Mark the significant results.
	plot_data[, significance := ifelse(
		FDR < FDR_threshold & abs(obs_log2FD) > log2FD_threshold,
		paste("FDR <", FDR_threshold, "& abs(Log2FD) >", round(log2FD_threshold, 2)),
		"n.s."
	)]

	plot_data[, significance := factor(significance, levels = c(
		paste("FDR <", FDR_threshold, "& abs(Log2FD) >", round(log2FD_threshold, 2)),
		"n.s."
	))]

	## Order the clusters by observed log2FD if requested.
	if (order_clusters) {
		plot_data[, clusters := fct_reorder(factor(clusters), desc(obs_log2FD))]
	}

	## Plot the results.
	p <- ggplot(plot_data, aes(x = clusters, y = obs_log2FD)) +
		geom_pointrange(aes(ymin = boot_CI_2.5, ymax = boot_CI_97.5, color = significance)) +
		theme_bw(base_size = font_size) +
	  theme(text = element_text(face = "bold")) +
		geom_hline(yintercept = log2FD_threshold, lty = 2) +
		geom_hline(yintercept = -log2FD_threshold, lty = 2) +
		geom_hline(yintercept = 0) +
		scale_color_manual(values = c("black", "grey")) +
		coord_flip()

	return(p)
}
