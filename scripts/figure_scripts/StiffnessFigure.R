library(here)
library(tidyverse)
library(ggpattern)
library(Hmisc)
library(ordinal)

# Load the stiffness data, rename and format columns
stiff <- read_csv(here("data/BehaviourData.csv")) %>%
  mutate(Date = as.Date(Date, format="%d/%m/%Y"),
         Bucket_ID = as.factor(Bucket_ID),
         Cuke_ID = as.factor(Cuke_ID),
         Unique_ID = paste(Bucket_ID, Cuke_ID,  sep = '_'))%>%
  select(-c("Activity_Score", "Number_lesions","Bodywall_lesions")) %>%
  mutate(Droop_score = replace_na(stiff$Droop_score, "mortality"),
         Squeeze_score = replace_na(stiff$Squeeze_score, "mortality")) %>%
  mutate(Droop_score = as.factor(Droop_score),
         Squeeze_score = as.factor(Squeeze_score)) %>%
  # Renaming the treatment factors
  mutate(Treatment = gsub("Room", "Warm", Treatment),
         Treatment = gsub("Heat", "Heat Wave", Treatment),
         # Reordering the treatments so they appear properly in the grid
         Treatment = fct_relevel(Treatment, 
                                 c("Heat Wave", "Warm", "Control")),
         # Reordering the factors in mortality stands out
         Droop_score = fct_relevel(Droop_score,
                                   c("mortality", 0, 1, 2)),
         Squeeze_score = fct_relevel(Squeeze_score,
                                   c("mortality", 0, 1, 2)))
         
  str(stiff)
  
#### PLOTTING DROOP DATA
stiffness_plot <-
  ggplot(data = stiff, 
         aes(x = as.factor(Date))) +
  geom_bar_pattern(aes(fill = Droop_score,
                       pattern = Droop_score),
                   alpha = 0.8, 
                   color = "black",
                   size = 0.5) +
  scale_pattern_manual(values = c('stripe', 'none', 'none', 'none'),
                       guide = 'none') +
  scale_x_discrete(breaks=c("2021-11-09","2021-11-10","2021-11-11", "2021-11-12","2021-11-13","2021-11-14","2021-11-15"),
                   labels=c("1", "2", "3", "4", "5","6", "7")) +
  xlab("Experiment Day") +
  #scale_x_date(date_labels = "%b%d", date_breaks="1 day")+
  geom_vline(xintercept=1.5, 
             linetype=1,
             size = 0.4) +
  geom_vline(xintercept=4.5, 
             linetype=1, 
             size = 0.4) +
  scale_y_continuous(expand=c(0,0)) +
  scale_fill_manual(name="Droop Score",
                    labels=c("Mortality", "0 - Full Droop", "1 - Partial Droop", "2 - No Droop"), 
                    values = c(mortality = "#A7A8AA",
                               "0" = "#DA7765",
                               "1" = "#F6CBA3",
                               "2" = "#FBEDD6")) +
  ylab("Number of Sea Cucumbers") +
  theme_bw() +
  theme(strip.text.y = element_text(size =12),
        panel.grid=element_blank()) +
  facet_grid(Treatment ~ .)

stiffness_plot

ggsave("StiffnessPlot.pdf",
       stiffness_plot, 
       device = "pdf",
       path = here("figures"))
#------------------------------------------------------------------------------
# "Squeeze" data refers to the squeeze trials we did in addition to the 'droop'
# trials as a way to measure stiffness. This measurement was ultimately omitted
# from the final manuscript so the code has been commented out below so that 
# this script can be run without issue.

##### PLOTTING SQUEEZE DATA
#squeeze_plot = 
#  ggplot(data =stiff, aes(x=as.factor(Date), fill=Squeeze_score))+
#  geom_bar(alpha=0.8, color="black", size=0.5) +
#  scale_x_discrete(breaks=c("2021-11-09","2021-11-10","2021-11-11", "2021-11-12","2021-11-13","2021-11-14","2021-11-15"),
#                   labels=c(1,2,3,4,5,6,7))+
#  xlab("Day")+
#  #scale_x_date(date_labels = "%b%d", date_breaks="1 day")+
#  geom_vline(xintercept=1.5, linetype=2)+
#  geom_vline(xintercept=4.5, linetype=2)+
#  scale_y_continuous(expand=c(0,0))+
#  ylab("# Sea Cucumbers")+
#  scale_fill_brewer(name="Squeeze Score",labels=c("0 - No Stiffness","1 - Partial Stiffness","2 - Full Stiffness"), 
#                    palette="OrRd", direction=1)+ 
#  theme_bw()+
#  theme(strip.text.y = element_text(size =12),
#        panel.grid=element_blank(),
#        legend.position="right")+
#  facet_grid(Treatment~.)
#squeeze_plot
#ggsave("figures/squeeze.jpg",plot=squeeze_plot, width=5, height=4)

#### PLOTTING CORRELATION BETWEEN SQUEEZE AND DROOP
#squeeze_droop_cor = ggplot(data=stiff, aes(x=Squeeze_score, y=Droop_score, color=Treatment))+
#  geom_jitter(width=0.2, height=0.2)+
#  scale_color_manual(labels=c("Control (12?C)","Room (17?C)","Heat (22?C)"), values=c("Gold", "Orange","Red"))+
#  theme_bw()+
#  theme(strip.text.y = element_text(size =12))+
#  facet_grid(Treatment~.)
#squeeze_droop_cor
#
#ggsave("figures/squeeze_droop_correlation.jpg",plot=squeeze_droop_cor, width=6, height=4)

## CALCULATING CORRELATION 
#rcorr(stiff$Squeeze_score,stiff$Droop_score, type="spearman") # looking at correlation 

##### SHATISTICS #####
# Running ordinal regressions on the data
#str(stiff)

#stiff_mod = clmm(Squeeze_score~ Treatment+as.factor(Date)+ (1|Unique_ID) +(1|Bucket_ID)+(1|Sea_Table),
#                 data = stiff) # squeeze
#tbl_regression(stiff_mod)

droop_mod= clmm(Droop_score~ Treatment + as.factor(Date)+ (1|Unique_ID) +(1|Bucket_ID)+(1|Sea_Table), data = stiff) # droop
tbl_regression(droop_mod)