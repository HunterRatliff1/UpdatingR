library(tidyverse)

### REVISION HISTORY
### 1. Created on 2019-11-19 when updating R
### 2. Modified to make it a script when installing
###    R on a new MacBook (2020-03-18)


#==============================================#
####            BEFORE UPGRADING            ####
#==============================================#

## Save a csv of currently installed packages
installed <- as.data.frame(installed.packages())
write.csv(installed, 'installed_previously.csv')





#------------------------------------------#
####   Upgrade to latest version of R   ####
#------------------------------------------#
# No code here



#------------------------------------#
####   Define our goal packages   ####
#------------------------------------#

## Read in the csv you wrote before upgrading
# installedPreviously <- read_csv('installed_previously.csv')$X1
installedPreviously <- read_csv("~/Downloads/R_packs.csv")$packages


whats_left <- function(goal_packages){
  ## goal_packages: Vector of all of the packages that you eventually want
  ##                installed
  ##
  ## RETURNS: vector of packages remaining to be installed
  
  current_packages <- rownames(as.data.frame(installed.packages()))
  remaing_to_be_installed <- setdiff(goal_packages, current_packages)
  
  return(remaing_to_be_installed)
}


#--------------------------------------#
####   install remaining packages   ####
#--------------------------------------#
whats_left(installedPreviously) %>%
  install.packages()

## Only install packages starting with a
whats_left(installedPreviously) %>%
  str_subset("^(a|A)") %>%
  install.packages()

## Only install first 10 packages
whats_left(installedPreviously)[1:10] %>%
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


## Need github install
devtools::install_github("ajdamico/lodown") 
devtools::install_github("sachsmc/rclinicaltrials")
devtools::install_github("briatte/ggnet")
devtools::install_github("Ram-N/weatherData")
devtools::install_github("ThomasSiegmund/D3TableFilter")
devtools::install_github("cran/zipcode")

# Still missing
whats_left(installedPreviously)


#--------------------------------------#
####   Update Renviron   ####
#--------------------------------------#
## Some packages store API keys in the system enviroment
## For me, it's under
## "/Library/Frameworks/R.framework/Versions/{version}/Resources/etc/Renviron"

# Find the path
R.home("etc")


