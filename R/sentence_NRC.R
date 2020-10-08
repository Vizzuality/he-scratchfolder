library(foreign)
library(plyr)
library(dplyr)

adm0 = read.dbf("country_data/gadm36_0.dbf")
adm_val = read.csv("country_data/country_val_MOL.csv")
grid_intersect = read.csv("country_data/gadm.csv")

sel_grid =grid_intersect %>%
  select(GID_0,Rar_amph,Rar_bird,Rar_mamm,Rar_rept,
         #Rar_cact,Rar_coni,
         Rar_all)

country_rar = 
  sel_grid %>%
  group_by(GID_0) %>%
  summarize(max_amph=max(Rar_amph),
            max_bird=max(Rar_bird),
            max_mamm=max(Rar_mamm),
            max_rept=max(Rar_rept),
            #max_cact=max(Rar_cact),
            #max_coni=max(Rar_coni),
            max_all=max(Rar_all)
  )
head(country_rar)


res_grid=grid_intersect %>%
  select(-Rar_amph,-Rar_bird,-Rar_mamm,-Rar_rept,
         -Rar_cact,-Rar_coni,
         -Rar_all, 
         -Rich_amph,	-Rich_bird,	-Rich_mamm,	-Rich_rept,	
         -Rich_cact,	-Rich_coni,	
         -Rich_all, 
         -ID, -FID_L0Glob,	-Shape__Are,	-Shape__Len, -OBJECTID, -Shape_Leng,	-Shape_Area)  %>%
  distinct()%>% 
  inner_join(country_rar, by = "GID_0")


get_bio_sentence = function(df){
  taxa_names = c("all","amphibians", "birds", "mammals", "reptiles"
                 #, "cacti", "conifers"
                 )
  max_vals = c(df$max_all, df$max_amph, df$max_bird, df$max_mamm, df$max_rept
               #, df$max_cact, df$max_coni
               )
  top_vals = which(max_vals == 10)
  nb_taxa = length(top_vals)
  sentence_tx = character()
  if(nb_taxa!=0){
    sel_taxa = taxa_names[top_vals]
    if("all"%in%sel_taxa){
      sentence_tx = "has high biodiversity rarity of terrestrial land vertebrates at a global scale. "
    }
    if("all"%in%sel_taxa&nb_taxa>1){
      sentence_tx2 = character()
      for (tx in 2: nb_taxa){ #for each taxa
        
        tx_bit = paste0(sel_taxa[tx], ", ")
        if(tx == nb_taxa-1){ #if the taxa we are in is before the last one, we remove the space and coma add "and"
          tx_bit = paste0(substr(tx_bit,1,nchar(tx_bit)-2), " and ")
        }
        if(tx == nb_taxa){#if the taxa we are in is the last one, we remove the space and coma and add a dot
          tx_bit = paste0(substr(tx_bit,1,nchar(tx_bit)-2), " is also high. ")
        }
        sentence_tx2 = paste0(sentence_tx2, tx_bit)
      }
      sentence_tx2 = paste0( " When analysed as single taxons, the rarity of ",sentence_tx2) 
      sentence_tx = paste0(sentence_tx, sentence_tx2)#paste0(substr(sentence_tx,1,nchar(sentence_tx)-2), sentence_tx2)
    }
  }
  return(sentence_tx)
  
}


get_bio_sentence(df = res_grid[which(res_grid$GID_0 =="ARG"),])

get_human_sentence = function(df){
  
  anthr_names = c("urban use", "irrigated agriculture", "rainfed agriculture", "rangeland")
  hum_levels = c("Less than a quarter of the country", "Less than half of the country", "More than half of the country","Most of the country")
  anth_vals = c(df$PROP_Urban, df$PROP_Irrig, df$PROP_Rainf,df$PROP_Range)
  
  anth_total = sum(anth_vals)
  main_act = anthr_names[which.max(anth_vals)]
  main_val = anth_vals[which.max(anth_vals)]
  hum_level = 
    ifelse(anth_total>0.75, hum_levels[4],
           ifelse(anth_total>0.5, hum_levels[3],
                  ifelse(anth_total>0.25, hum_levels[2],hum_levels[1])))
  sentence_hum = paste0(hum_level, " is used for human activities, in its majority by ", main_act, ". ")
  return(sentence_hum)
}
get_human_sentence(df=res_grid[1,])


sentence_list = list()
for (i in 1:length(res_grid$GID_0)){
  df = res_grid[i,]
  country = df$NAME_0
  b_sent = get_bio_sentence(df)
  h_sent = get_human_sentence(df)
  if(length(b_sent)==0){
    
    sentence = paste("In",country,  tolower(h_sent))
    
  }else{sentence = paste(country, b_sent, h_sent)}
  
  sentence_list[[i]]=sentence
}
sentence_res = ldply(sentence_list)
sentence_res$GID_0 = res_grid$GID_0
head(sentence_res)
names(sentence_res)[1] = "sentence"
#sentence_res$V1
res_grid_sentence = res_grid%>% inner_join(sentence_res, by = "GID_0")
write.csv(sentence_res, "nrc_sentence_no_trees.csv")
