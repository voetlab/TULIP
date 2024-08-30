#script to visualise the called patients of the analysis, filter (both strict & loose) and write to a csv for further analysis
## Author: Jarne Geurts


## load packages & data

suppressMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(tibble)
  library(plotly)
  library(htmlwidgets)
})
sessionInfo()
args<-commandArgs(TRUE)
GEX_file <- args[1]
ATAC_file <- args[2]
MOC <- args[3]
results_folder <- args[4]
pool <-args[5]
output_path <- file.path(results_folder,MOC,paste("Pool",pool,sep=""),"Combined", sep = "")


#manipulate the data to get a merged df for sankey plot

GEX <- read.csv(GEX_file, sep = "\t")
ATAC <- read.csv(ATAC_file, sep = "\t")
subset_ATAC <- subset(ATAC, select = c(cell, donor_id))
subset_ATAC$donor_id <- paste("ATAC_", subset_ATAC$donor_id, sep = "")
subset_GEX <- subset(GEX, select = c(cell, donor_id))
subset_GEX$donor_id <- paste("GEX_", subset_GEX$donor_id, sep = "")
merged_df <- merge(subset_ATAC, subset_GEX, by="cell", all= TRUE)
head(merged_df)


co_occurrence_matrix_table <- table(merged_df$donor_id.x, merged_df$donor_id.y)
co_occurrence_matrix <-as.data.frame.matrix(co_occurrence_matrix_table)
co_occurrence_long <- co_occurrence_matrix %>%
  mutate(source = rownames(co_occurrence_matrix)) %>%
  tidyr::pivot_longer(
    cols = -source,
    names_to = "target",
    values_to = "value"
  )



labels <- unique(c(co_occurrence_long$source, co_occurrence_long$target))


co_occurrence_long$source_index <- match(co_occurrence_long$source, labels) - 1
co_occurrence_long$target_index <- match(co_occurrence_long$target, labels) - 1


fig <- plot_ly(
  type = "sankey",
  orientation = "h",
  node = list(
    label = labels,
    pad = 15,
    thickness = 20,
    line = list(color = "black", width = 0.5)
  ),
  link = list(
    source = co_occurrence_long$source_index,
    target = co_occurrence_long$target_index,
    value = co_occurrence_long$value
  )
)

fig <- fig %>% layout(
  title = "Sankey Diagram of MOC",
  font = list(size = 10)
)

fig

htmlwidgets::saveWidget(as_widget(fig), file.path(output_path,"/sankey.html"),selfcontained = FALSE)

ggplot(data = co_occurrence_long, aes(x=source, y=target, fill=value)) + 
  geom_tile() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size = 15), axis.text.y = element_text( size = 15) ) + 
  geom_text(aes(label = value), color = "white", size = 4) 

ggsave(c("overlap.pdf"), device="pdf", path=output_path, dpi = 300, width = 10, height = 10)

# Create dataframe
Final_df <- merged_df %>%
  mutate(donor_id.x = sub("^ATAC_", "", donor_id.x))
Final_df <- Final_df %>%
  mutate(donor_id.y = sub("^GEX_", "", donor_id.y))
Final_df <- Final_df %>%
  mutate(Final_call = ifelse(donor_id.x == donor_id.y, donor_id.x, "No_Overlap"))
Filtered_df <- Final_df 
Filtered_df$Final_call <- ifelse(
  Filtered_df$Final_call == "No_Overlap",
  ifelse(
    Filtered_df$donor_id.x == "unassigned" & Filtered_df$donor_id.y == "doublet" | Filtered_df$donor_id.y == "unassigned" & Filtered_df$donor_id.x == "doublet",
    "Still_Removed",
    ifelse(
      grepl("^Patient_", Filtered_df$donor_id.x),
      Filtered_df$donor_id.x,
      ifelse(grepl("^Patient_", Filtered_df$donor_id.y), Filtered_df$donor_id.y, "No_Overlap")
    )
  ),
  Filtered_df$Final_call
)
csv_path <-file.path(output_path, paste(MOC,"_",pool,"_output_less_stringent.csv", sep = ""))
csv_path
write.csv(Filtered_df, csv_path, row.names = FALSE)
