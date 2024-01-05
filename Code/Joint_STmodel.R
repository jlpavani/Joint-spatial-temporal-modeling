library(dplyr)
library(rgdal)
library(spdep)
library(leaflet)
library(leafsync)
library(INLA)
library(INLAMSM)

# **************************************************************************** #
# Load Data
# **************************************************************************** #
load("dta_deng_chik_2017.RData")
data <- data[order(data$id),]

Output.Areas <- readOGR(".", "CE_Municipios_2019") 

# Spatial Adjancency Matrix
W.nb <- poly2nb(Output.Areas, row.names = 1:length(Output.Areas)) 
W.sp <- as(nb2mat(W.nb, style = "B"), "Matrix")

# Temporal Adjancency Matrix
W.tm <- Diagonal(length(unique(data$SE)), x = 0)                                                       
W.tm[1, 1 + 1] <- 1
W.tm[length(unique(data$SE)), length(unique(data$SE)) - 1] <- 1
for(i in 2:(length(unique(data$SE)) - 1)){
  W.tm[i, i - 1] <- 1
  W.tm[i, i + 1] <- 1
}

# **************************************************************************** #
# Joint model
# **************************************************************************** #
# create variables related to spatial and time IDs
data$id_time <- rep(rep(1:length(unique(data$SE)), each = length(unique(data$id_area))),2)

# Create intercept
data$intercept <- as.factor(data$disease)

# Create dummy indices for space and time
data$s.dummy <- NA; data$t.dummy <- NA

# Create spacial indices for specific effects
data$s.1 <- NA
data$s.1[data$disease == 1] <- as.numeric(as.factor(data$id_area[data$disease == 1]))

data$s.2 <- NA
data$s.2[data$disease == 2] <- as.numeric(as.factor(data$id_area[data$disease == 2]))

# Create temporal indices for specific effects
data$t.1 <- NA
data$t.1[data$disease == 1] <- as.numeric(as.factor(data$id_time[data$disease == 1]))

data$t.2 <- NA
data$t.2[data$disease == 2] <- as.numeric(as.factor(data$id_time[data$disease == 2]))

# Indices for spatial  disease-specific effects
data$id_area1 <- data$s.1; data$id_area2 <- data$s.2

# Indices for temporal  disease-specific effects
data$id_time1 <- data$t.1; data$id_time2 <- data$t.2

# Spatial and temporal weights have been assigned a log-Normal prior with zero mean and 
# precision 1/5.9 (similarly as in Downing et al., 2008)
prior.beta.s <- list(prior = "normal", param = c(0, 1 / 5.9), fixed = FALSE, initial = 0.01)
prior.beta.t <- list(prior = "normal", param = c(0, 1 / 5.9), fixed = FALSE, initial = 0.01)

# Flat prior on sigma: Ugarte et al. (2018):
prior.prec <- list(prior = "expression: logdens = -log_precision / 2; return(logdens)", initial = 0)

inla.scale <- FALSE

formula <- observed ~ -1 + intercept + temperature + humidity + 
  f(id_area1, model = "besag",  scale.model = inla.scale, graph = W.sp, hyper = list(prec = prior.prec)) + 
  f(id_area2, model = "besag",  scale.model = inla.scale, graph = W.sp, hyper = list(prec = prior.prec)) + 
  f(s.dummy, model = "besag",  scale.model = inla.scale, graph = W.sp, hyper = list(prec = prior.prec)) + 
  f(s.1, copy = "s.dummy",  range = c(0, Inf), hyper = list(beta = prior.beta.s)) + 
  f(s.2, copy = "s.dummy",  range = c(0, Inf), hyper = list(beta = prior.beta.s)) + 
  f(id_time1, model = "besag", scale.model = inla.scale, graph = W.tm, hyper = list(prec = prior.prec)) + 
  f(id_time2, model = "besag", scale.model = inla.scale, graph = W.tm, hyper = list(prec = prior.prec)) +
  f(t.dummy, model = "besag", scale.model = inla.scale, graph = W.tm, hyper = list(prec = prior.prec)) + 
  f(t.1, copy = "t.dummy",  range = c(0, Inf), hyper = list(beta = prior.beta.t)) + 
  f(t.2, copy = "t.dummy",  range = c(0, Inf), hyper = list(beta = prior.beta.t)) 


out_fit_zip <- inla(formula,  data = data, E = expected, family = "zeroinflatedpoisson1", 
                    verbose = FALSE, control.predictor = list(compute=TRUE), 
                    control.compute = list(dic = TRUE, waic = TRUE, config = TRUE),
                    control.inla(strategy = "laplace"))

out_fit_zip <- inla.rerun(out_fit_zip)
summary(out_fit_zip)