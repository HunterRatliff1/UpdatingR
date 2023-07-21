library(devtools)
library(stringr)
library(dplyr)
library(fs)
library(purrr)
library(readr)
library(knitr)

# Currently installed packages
installed <- as.data.frame(installed.packages(), stringsAsFactors = F)$Package

# Regular expression to identify packages
pkg_regEx <- "[[:alnum:]\\.]+"
search_regEx <- str_glue("((library|require)\\({pkg_regEx}\\))|({pkg_regEx}\\:\\:)")

str_detect(installed, pkg_regEx) # check that works


extract_pkg_from_file <- function(path){
  out <- tryCatch(
    {
      # Read the lines, extract the names of packages
      # returns a list with one item per line of code
      ls <- readr::read_lines(path) %>%
        str_extract_all(search_regEx) %>%
        map(str_remove, "library|require") %>%
        map(str_extract, pkg_regEx) 
      
      # Map these into a df in long format with the row numbers
      tibble(file = path,
             pkg = ls) %>%
        mutate(line = row_number()) %>%
        tidyr::unnest_longer(pkg) %>%
        filter(!is.na(pkg)) %>%
        
        # Collapse packages on multiple lines
        arrange(line) %>%
        group_by(file, pkg) %>%
        summarise(location = str_c(line, collapse=', '),
                  .groups = "drop") %>%
        ungroup() 
    },
    error=function(cond) {
      message("Problem:")
      message(cond)
      # Choose a return value in case of error
      return(tibble(file = path))
    }
  )
  return(out)
}




# fs::dir_tree("~/Github/UpdatingR")
tictoc::tic()
df <- "~/Github/" %>%
  fs::dir_ls(recurse = T) %>%
  fs::path_filter(regexp = "rsconnect", invert = TRUE) %>%
  fs::path_filter(regexp = "\\.(R|Rmd)$") %>%
  map_df(extract_pkg_from_file)
tictoc::toc()

df %>%
  mutate(file   = str_remove(file, "^\\/[:alnum:]+\\/[:alnum:]+\\/Github\\/"),
         Parent = str_extract(file, "^[[:alnum:]_]+(?=\\/)"),
         file   = str_remove(file, "^[[:alnum:]_]+\\/")) %>%
  relocate(Parent) %>%
  count(Parent, sort=T) %>% 
  View()

# # Read the lines, extract the names of packages
# # returns a list with one item per line of code
# x <- c("dplyr is cool",
#        "use dplyr::mutate()",
#        "don't use dplyr::mutate
#   library(tidyr) works the same as require(ggplot)") %>%
#   str_extract_all(search_regEx) %>%
#   map(str_remove, "library|require") %>%
#   map(str_extract, pkg_regEx) 
# 
# tibble(file= "test", pkg = x) %>%
#   mutate(line = row_number()) %>%
#   tidyr::unnest_longer(pkg) %>%
#   filter(!is.na(pkg)) %>%
#   arrange(line) %>%
#   group_by(file, pkg) %>%
#   summarise(location = str_c(line, collapse=', ')) %>%
#   ungroup() 

# get_Rmd_source <- function(fname) {
#   withr::with_tempfile("temp", {
#     knitr:::purl(fname, output=temp, quiet=TRUE)
#     read_lines(temp)
#   })
# }
# "~/Github/APA/Austin Pets Alive/03 Dog Walking/rsconnect/documents/TLAC_Dog_Walking.Rmd" %>% extract_pkg_from_file()
