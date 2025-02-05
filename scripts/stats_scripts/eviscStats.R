# Statistics: Modelling the impact of treatment (and other variables) on 
# evisceration and spawning variables.

# Be sure to run BinaryVariables.R prior to running this script, as the data 
# comes from IndividualData, a dataframe generated in that script.
library(gamlss)
library(tidyverse)

# Drop the final row (all NAs) and the death_time and in_activity columns 
# (contain NAs) from `IndividualData`, so we can use gamlss models.
EviscData <- IndividualData %>%
  dplyr::select(-c(death_time, in_activity))

# 1. EVISCERATION: modelling the impact of treatment, weight, and guts status, 
# along with random effects, on evisceration. Based on data frame 
# `EviscData`.

sum(EviscData$evisceration)
# N = 12 eviscerated

# Determining the distribution of the data, based on our knowledge that it 
# follows a binomial distribution.
fitDist(evisceration, data = EviscData, type = "binom", try.gamlss = T)

# The FULL MODEL. Evisceration is dependent on treatment, and also cucumber 
# weight and pooping status. Sea table and table position are included as 
# random effects
evisc.mod.full <- gamlss(evisceration ~ 
                           treatment + weight_g + poop + bucketID +
                           random(tableID),
                         family = BI(),
                         data = EviscData)


# The NULL MODEL.
evisc.mod.null <- gamlss(evisceration ~ 1,
                         family = BI(),
                         data = EviscData)

# Forwards selection.
fwd.evisc.mod <- stepGAIC(evisc.mod.null, 
                              scope = list(lower = evisc.mod.null,
                                           upper = evisc.mod.full),
                              direction = "forward", 
                              trace = F)
formula(fwd.evisc.mod)
## evisceration ~ poop + weight_g
summary(fwd.evisc.mod)
# poop (p = 0.0163) and weight (p = 0.0383) are both significant in explaining 
# variation in evisceration. Weight estimate = -0.004309.

# Backwards selection
bwd.evisc.mod <- stepGAIC(evisc.mod.null, 
                          direction = "backward", 
                          trace = F)
formula(fwd.evisc.mod)
## evisceration ~ weight_g + poop
summary(fwd.evisc.mod)

# It makes sense that pooping explains a significant amount of variation given 
# that a cucumber that is not pooping likely doesn't have guts, so it cannot
# eviscerate. We therefore reran the above model without pooping included in 
# the full model. Just learning about weird model stuff; this isn't a stats 
# step for the final published material.

evisc.mod.full <- gamlss(evisceration ~ 
                           treatment + weight_g + bucketID +
                           random(tableID),
                         family = BI(),
                         data = EviscData)

# Forwards selection.
fwd.evisc.mod <- stepGAIC(evisc.mod.null, 
                          scope = list(lower = evisc.mod.null,
                                       upper = evisc.mod.full),
                          direction = "forward", 
                          trace = F)
formula(fwd.evisc.mod)
## evisceration ~ poop + weight_g
summary(fwd.evisc.mod)
# weight (p = 0.0383) along is not significant in explaining variation in the 
# model.

# Backwards selection for the original model as a sanity check on the validity
# of our forwards selection methods.
bwd.evisc.mod <- stepGAIC(evisc.mod.null, 
                          direction = "backward", 
                          trace = F)
formula(fwd.evisc.mod)
## evisceration ~ weight_g + poop
summary(fwd.evisc.mod)



#-----------------------------------------------------------------------------
# 2. RESP_EVISC: modelling the impact of treatment, weight, and guts status, 
# along with random effects, on respiratory evisceration, which occurred only 
# twice, in the 22C treatment Based on data frame `EviscData`.

# Determining the distribution of the data, based on our knowledge that it 
# follows a binomial distribution.
fitDist(resp_evisc, data = EviscData, type = "binom", try.gamlss = T)

# The FULL MODEL. Respiratory evisceration is dependent on treatment, and also 
# cucumber weight and pooping status. Sea table and table position are included 
# (via tableID) as random effects.
respEvisc.mod.full <- gamlss(resp_evisc ~ 
                           treatment + weight_g + poop + 
                           random(tableID),
                         family = BI(),
                         data = EviscData)

# The NULL MODEL.
respEvisc.mod.null <- gamlss(resp_evisc ~ 1,
                         family = BI(),
                         data = EviscData)

# Forwards selection.
fwd.respEvisc.mod <- stepGAIC(respEvisc.mod.null, 
                          scope = list(lower = respEvisc.mod.null,
                                       upper = respEvisc.mod.full),
                          direction = "forward", 
                          trace = F)
formula(fwd.respEvisc.mod)
## resp_evisc ~ treatment
summary(fwd.respEvisc.mod)
## treatment is not significant but is the best explanation. p = 0.995. This is
# because there's no variance in 2 of the treatmnets (because phenotype was 
# not observed in 'room' and 'control').