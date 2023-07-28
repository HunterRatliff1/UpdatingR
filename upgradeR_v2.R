library(tidyverse)
library(devtools)
library(dplyr)
library(purrr)
library(stringr)

### REVISION HISTORY
### 1. Created on 2019-11-19 when updating R
### 2. Modified to make it a script when installing
###    R on a new MacBook (2020-03-18)
### 3. Expanded to determine if installed from github
###    Done when upgrading to R 4.2


#==============================================#
####            BEFORE UPGRADING            ####
#==============================================#

## Save a csv of currently installed packages
installed <- as.data.frame(installed.packages(), stringsAsFactors = F) %>%
  mutate(Priority = tidyr::replace_na(Priority, "N/A")) %>%
  filter(Priority != "base") %>%
  
  pull(Package) %>%
  map_df(devtools::package_info, dependencies = F) %>%
  tibble() %>%
  select(package, version=ondiskversion, date, source) %>%
  mutate(pkg_source = str_extract(source, "^[:alnum:]+"),
         source     = str_extract(source, "\\(.+\\)"),
         source     = str_remove(source, "\\("),
         source     = str_remove(source, "\\)")) %>%
  mutate(Title = map_chr(package, ~packageDescription(.x)[["Title"]]),
         Descp = map_chr(package, ~packageDescription(.x)[["Description"]]),
         )


readr::write_csv(installed, str_glue("packages/{lubridate::today()}_installed_previously.csv"))


#------------------------------------------#
#      Upgrade to latest version of R   ----
#------------------------------------------#
# No R code here
#
# Be sure to run the `sudo pkgutil -- forget <pkg>` code
# in Terminal to prevent R from uninstalling the current version
# when upgrading


#------------------------------------#
#      Define our goal packages   ----
#------------------------------------#

## Read in the csv you wrote before upgrading
installedPreviously <- rstudioapi::selectFile() %>%
  readr::read_csv() %>%
  mutate(keep = TRUE)

# If there are packages you don't want to use, mark `keep`
# as false

## First make a list of all  packages
prior_pkgs <- installedPreviously %>%
  filter(keep) %>%
  # filter(pkg_source=="CRAN") %>%
  pull(package)

## Data frame for github only packages
github_pkgs <- installedPreviously %>%
  filter(pkg_source=="Github") %>%
  filter(!package %in% rownames(as.data.frame(installed.packages()))) %>%
  mutate(repo = str_extract(source, "^.+(?=@)"))


whats_left <- function(goal_packages){
  ## goal_packages: Vector of all of the packages that you eventually want
  ##                installed
  ##
  ## RETURNS: vector of packages remaining to be installed
  
  current_packages <- rownames(as.data.frame(installed.packages()))
  remaing_to_be_installed <- setdiff(goal_packages, current_packages)
  
  return(remaing_to_be_installed)
}




#---------------------------------#
#      install CRAN packages   ----
#---------------------------------#
# I'd suggest starting with the packages
# you use most commonly
whats_left(prior_pkgs) %>%
  install.packages()

## Only install packages starting with <letter>
whats_left(prior_pkgs) %>%
  str_subset("^(g|G)") %>%
  install.packages()

## Only install first x packages
whats_left(prior_pkgs)[1:100] %>%
  install.packages()


#-----------------------------------#
####   install GITHUB packages   ####
#-----------------------------------#
# Try CRAN first
github_pkgs %>%
  filter(!keep) %>%
  filter(!package %in% c("weatherData", "lehdr", "D3TableFilter")) %>%
  pull(package) %>%
  install.packages()



# Then try github
filter(github_pkgs, package %in% intersect(
  whats_left(installedPreviously$package), 
  github_pkgs$package) 
  ) %>%
  pull(repo) %>%
  walk(remotes::install_github)


# Still missing
whats_left(installedPreviously$package) %>%
  install.packages()

#========================#
####   KNOWN ISSUES   ####
#========================#

## All the Bayesian packages require JAGS, which must be
## installed with homebrew on new machines

# remotes::install_github   same as   devtools::install_github
devtools::install_github("rasmusab/bayesian_first_aid")
devtools::install_github("vdorie/bartCause")

# Terminal> brew install jags


# ## Need github install
# devtools::install_github("ajdamico/lodown")
# devtools::install_github("sachsmc/rclinicaltrials")
# devtools::install_github("briatte/ggnet")
# 
# devtools::install_github("cran/zipcode")


#---------------------------#
####   Update Renviron   ####
#---------------------------#
## Some packages store API keys in the system environment
## For me, it's under
## "/Library/Frameworks/R.framework/Versions/{version}/Resources/etc/Renviron"

# Find the path using...
R.home("etc")
# usethis::edit_r_environ()

# As of my upgrade to v4.2, I haven't had to update these values






  





