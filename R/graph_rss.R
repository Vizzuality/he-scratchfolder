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
