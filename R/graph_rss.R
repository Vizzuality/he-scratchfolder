d = read.csv("/Users/gretacvega/rapid_test.csv")
head(d)
summary(d)
library(ggplot2)
library(plyr)
library(dplyr)

m = lm(time_s ~ size_km2, d %>% 
     filter(success==TRUE))

eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2, 
                 list(a = format(unname(coef(m)[1]), digits = 2),
                      b = format(unname(coef(m)[2]), digits = 2),
                      r2 = format(summary(m)$r.squared, digits = 3)))
lab = as.character(as.expression(eq))

ggplot(data = d %>% 
         filter(success==TRUE), aes(x = size_km2, y = time_s))+
  geom_smooth(method='lm', formula= y~x, lty = 2, fill = "blue", alpha =0.2)+
  geom_point(aes(  shape = is_coastal, fill = success, colour = success), 
             #fill = "blue", colour = "blue",
             size = 5, alpha = 0.6)+
  geom_point(data = d %>% 
               filter(success==FALSE), aes(x = size_km2, y = time_s, shape = is_coastal, fill = success, colour = success),
             #fill = "red", colour = "red",
             size = 5, alpha = 0.6)+
  #geom_text(aes(x = size_km2, y = time_s, label = id), nudge_x = 100)+
  geom_text(x = 500000, y = 75, label = lab, parse = TRUE)+
  scale_shape_manual(values = c(22,21), name = "The polygon covers land and sea")+
  scale_fill_manual(values = c("red", "blue"), name = "Job succeeded")+
  scale_colour_manual(values = c("red", "blue"), name = "Job succeeded")+
  scale_x_continuous(breaks= seq(0,5000000, 500000), name = "Area in sqkm")+
  scale_y_continuous(name = "Time in seconds")+
  ggtitle("Testing spatial rapid summaries")+
  theme_bw()+
  theme(legend.position = "top")





####profile
library(reshape2)
d = read.csv("/Users/gretacvega/Desktop/steps/Sheet 2-Table 1.csv")
dd = d %>% 
  add_row(Geoprocessing.Step = "Start", no_python=0, Python=0, 
          .before = 1) %>%
  mutate(id = as.numeric(rownames(.))) %>% 
  mutate(noPythonCum = cumsum(no_python), pythonCum = cumsum(Python)) %>% 
  mutate(noPythonCum = noPythonCum/sum(d$no_python), pythonCum = pythonCum/sum(d$Python)) %>%
  melt(id.vars = c("id", "Geoprocessing.Step", 
                   #"steptype", 
                   "no_python", "Python" )) %>% 
  mutate( steptype = ifelse((no_python == 0 & variable == "noPythonCum"),1,
                             ifelse((Python == 0 & variable == "pythonCum"),
                                    1,0)))

ggplot(data = dd, aes(x = id, y = value))+
  geom_line(aes( group = variable, colour = variable))+
  geom_point(aes(alpha=as.factor(steptype), colour = variable))+
  geom_text(data = dd %>% filter(steptype == 0 & Geoprocessing.Step != "Calculate Value"),
            aes(label=Geoprocessing.Step, colour = variable,), check_overlap = TRUE, size = 3,
            nudge_x = 0.25,
            nudge_y = -0.02, 
            hjust = 0)+
  geom_text(data = dd %>% filter(steptype == 0 & Geoprocessing.Step == "Calculate Value"),
            aes(label=Geoprocessing.Step, colour = variable), check_overlap = TRUE, size = 5, x =c(3,10.8),y =c(0.9,0.999),
            nudge_y = 0.05, 
            nudge_x = -2,
            hjust = 0)+
  scale_alpha_manual(values = c(1,0), guide = 'none')+
  scale_y_continuous(name = "Processing time", labels = scales::percent)+
  scale_x_continuous(name = "Geoprocessing Steps", breaks = seq(-2,14,2), limits = c(0,14))+
  scale_colour_manual(name = "Uses Calculate Value", labels = c("FALSE", "TRUE"), values = c("red", "blue") )+
  theme_bw()+
  theme(legend.position = "top")+
  ggtitle("Comparison of workflows in arcgis Pro")
