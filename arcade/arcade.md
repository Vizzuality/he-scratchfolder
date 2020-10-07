<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Arcade expressions to create pop ups in arcgis online](#arcade-expressions-to-create-pop-ups-in-arcgis-online)
  - [First example: create a sentence with the mean human modification and the main type of human activity](#first-example-create-a-sentence-with-the-mean-human-modification-and-the-main-type-of-human-activity)
    - [Example output:](#example-output)
  - [Second example: create a sentence with the proportion of protection](#second-example-create-a-sentence-with-the-proportion-of-protection)
    - [Example output:](#example-output-1)
  - [Third example: Combining arcade expressions in the pop up](#third-example-combining-arcade-expressions-in-the-pop-up)
    - [{expression/expr2}](#expressionexpr2)
    - [{expression/expr1}](#expressionexpr1)
    - [Example output](#example-output)
  - [Fourth example: creating a pop up for overlapping points](#fourth-example-creating-a-pop-up-for-overlapping-points)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



## Arcade expressions to create pop ups in arcgis online

The tutorial used to create these expressions is [here](https://github.com/Esri/arcade-expressions/blob/master/popup/top-five-list.md). 

### First example: create a sentence with the mean human modification and the main type of human activity

```javascript
    var numTopValues = 1;
     var groups = [
      { value: $feature.prop_Urban, alias: "urban"},
      { value: $feature.prop_Rainfed, alias: "rainfed agriculture"},
      { value: $feature.prop_Irrigated, alias: "irrigated agriculture"},
      { value: $feature.prop_Rangeland, alias: "rangeland"}
      // ADD MORE FIELDS AS NECESSARY
    ];
    function getValuesArray(a){
      var valuesArray = []
      for(var i in a){
        valuesArray[i] = a[i].value;
      }
      return valuesArray;
    }
    
    function findAliases(top5a,fulla){
      var aliases = [];
      var found = "";
      for(var i in top5a){
        for(var k in fulla){
          if(top5a[i] == fulla[k].value && Find(fulla[k].alias, found) == -1){
            found += fulla[k].alias;
            aliases[Count(aliases)] = {
              alias: fulla[k].alias,
              value: top5a[i]
            };
          }
        }
      }
      return aliases;
    }
    
    function getTopGroups(groupsArray){
        
      var values = getValuesArray(groupsArray);
      var top5Values = IIF(Max(values) > 0, Top(Reverse(Sort(values)),numTopValues), "There is no main human modification.");
      var top5Aliases = findAliases(top5Values,groupsArray);
        
      if(TypeOf(top5Values) == "String"){
        return top5Values;
      } else {
        var content = "";
        for(var i in top5Aliases){
          content += "The main human activity is "+ top5Aliases[i].alias + " which covers " + Text(top5Aliases[i].value, "#,###") + "% of the area.";
          //content += IIF(i < numTopValues-1, TextFormatting.NewLine, "");
        }
      }
        
      return content;
    }
     
    var hum_level = ""
    hum_level = IIF($feature.MEAN <= 0.1, "low", IIF($feature.MEAN <= 0.4,"moderate", IIF($feature.MEAN <= 0.7, "high", "very high")))
    
    "In this area, the mean Human modification is " + hum_level + " (" + round($feature.MEAN,2) + ").  "+ getTopGroups(groups) 
```
#### Example output: 
> In this area, the mean Human modification is high (0.5). The main
> human activity is rainfed agriculture which covers 86% of the area.

### Second example: create a sentence with the proportion of protection

```javascript
    var numTopValues = 1;
     var groups = [
      { value: $feature.comm_prot_prop, alias: "community"},
      { value: $feature.not_comm_prot_prop, alias: "non-community"}
      // ADD MORE FIELDS AS NECESSARY
    ];
    function getValuesArray(a){
      var valuesArray = []
      for(var i in a){
        valuesArray[i] = a[i].value;
      }
      return valuesArray;
    }
    
    function findAliases(top5a,fulla){
      var aliases = [];
      var found = "";
      for(var i in top5a){
        for(var k in fulla){
          if(top5a[i] == fulla[k].value && Find(fulla[k].alias, found) == -1){
            found += fulla[k].alias;
            aliases[Count(aliases)] = {
              alias: fulla[k].alias,
              value: top5a[i]
            };
          }
        }
      }
      return aliases;
    }
    
    function getTopGroups(groupsArray){
        
      var values = getValuesArray(groupsArray);
      var top5Values = IIF(Max(values) > 0, Top(Reverse(Sort(values)),numTopValues), "There is no protection");
      var top5Aliases = findAliases(top5Values,groupsArray);
        
      if(TypeOf(top5Values) == "String"){
        return top5Values;
      } else {
        var content = "";
        for(var i in top5Aliases){
          content += "The main protection is " + top5Aliases[i].alias ;
          //content += IIF(i < numTopValues-1, TextFormatting.NewLine, "");
        }
      }
        
      return content;
    }
     
    
    
    "In this area, " + round($feature.all_prot_prop,1) + "% is protected. "+ getTopGroups(groups) +"."
```

#### Example output: 
> In this area, 32.7% is protected. The main protection is non-community. 

### Third example: Combining arcade expressions in the pop up
Content in the configure pop up (it has styling buttons):

> **{expression/expr3}** **Human Modification**
> 
> **Mean Score: {MEAN}**
> 
> {expression/expr0}  
>   
> 
> Proportion Protected {expression/expr2}  
> 
> {expression/expr1}     
> _Human Modification Score is dimentionless and ranges from 0 (no modification) to 1 (complete modification)._
#### {expression/expr3}
```javascript
    
    function hum_class(mean_value) {
        var hum_level = ""
        var hum_level = IIF(mean_value <= 0.1, "Low", IIF(mean_value <= 0.4,"Moderate", IIF(mean_value <= 0.7, "High", "Very high")))
        return hum_level
        
    } 
    hum_class($feature.MEAN)
```

#### {expression/expr0}
```javascript
    var numTopValues = 4;
     var groups = [
      { value: $feature.prop_Urban, alias: "Urban"},
      { value: $feature.prop_Rainfed, alias: "Rainfed agriculture"},
      { value: $feature.prop_Irrigated, alias: "Irrigated agriculture"},
      { value: $feature.prop_Rangeland, alias: "Rangeland"}
      // ADD MORE FIELDS AS NECESSARY
    ];
    function getValuesArray(a){
      var valuesArray = []
      for(var i in a){
        valuesArray[i] = a[i].value;
      }
      return valuesArray;
    }
    
    function findAliases(top5a,fulla){
      var aliases = [];
      var found = "";
      for(var i in top5a){
        for(var k in fulla){
          if(top5a[i] == fulla[k].value && Find(fulla[k].alias, found) == -1){
            found += fulla[k].alias;
            aliases[Count(aliases)] = {
              alias: fulla[k].alias,
              value: top5a[i]
            };
          }
        }
      }
      return aliases;
    }
     
    function getTopGroups(groupsArray){
        
      var values = getValuesArray(groupsArray);
      var top5Values = IIF(Max(values) > 0, Top(Reverse(Sort(values)),numTopValues), "no human modification");
      var top5Aliases = findAliases(top5Values,groupsArray);
        
      if(TypeOf(top5Values) == "String"){
        return top5Values;
      } else {
        var content = "";
        for(var i in top5Aliases){
          content += top5Aliases[i].alias + ": " + round(top5Aliases[i].value, 1) + "%";
          content += IIF(i < numTopValues-1, TextFormatting.NewLine, "");
        }
      }
        
      return content;
    }
     
    getTopGroups(groups);
```
#### {expression/expr2}
```javascript
    function textValue(prot_value)
    {
    var content = ""
    content = iif(prot_value>0, round(prot_value,1) + "%", "-")
    return content
    }
    textValue($feature.all_prot_prop)
```
#### {expression/expr1}
```javascript
    var numTopValues = 2;
     var groups = [
      { value: $feature.comm_prot_prop, alias: "Community protection"},
      { value: $feature.not_comm_prot_prop, alias: "Non-community protection"}
      // ADD MORE FIELDS AS NECESSARY
    ];
    function getValuesArray(a){
      var valuesArray = []
      for(var i in a){
        valuesArray[i] = a[i].value;
      }
      return valuesArray;
    }
    
    function findAliases(top5a,fulla){
      var aliases = [];
      var found = "";
      for(var i in top5a){
        for(var k in fulla){
          if(top5a[i] == fulla[k].value && Find(fulla[k].alias, found) == -1){
            found += fulla[k].alias;
            aliases[Count(aliases)] = {
              alias: fulla[k].alias,
              value: top5a[i]
            };
          }
        }
      }
      return aliases;
    }
     
    function getTopGroups(groupsArray){
        
      var values = getValuesArray(groupsArray);
      var top5Values = IIF(Max(values) > 0, Top(Reverse(Sort(values)),numTopValues), "no protection");
      var top5Aliases = findAliases(top5Values,groupsArray);
        
      if(TypeOf(top5Values) == "String"){
        return top5Values;
      } else {
        var content = "";
        for(var i in top5Aliases){
          content += top5Aliases[i].alias + ": " + round(top5Aliases[i].value, 1) + "%";
          content += IIF(i < numTopValues-1, TextFormatting.NewLine, "");
        }
      }
        
      return content;
    }
     
    getTopGroups(groups);
```
#### Example output

> **Low** **Human Modification**
> **Mean Score:  0.02**
>
> Urban: 0.4%   
> Rainfed agriculture: 0%   
> Irrigated agriculture: 0%  
> Rangeland: 0%  
> 
> **Proportion Protected 65.3%**
>
> Non-community protection: 32.2%   
> Community protection: 0.2%     
> _Human Modification Score is dimentionless and ranges from 0 (no modification) to 1 (complete modification)._

### Fourth example: creating a pop up for overlapping points
There are functions to spatially check the overlap of features, but in this case it is possible to use the fields indicating the `latitude` and `longitude`. Some new functions used here are: Distinct, Sort, Reverse

```javascript
var point_lat = $feature['Latitude']
var point_long = $feature['Longitude']
var filterStatement_lat = "Latitude = @point_lat"
var filterStatement_long = "Longitude = @point_long"
var lay_lat = Filter($layer, filterStatement_lat)
var lay_long = Filter($layer, filterStatement_long)
var method = $feature['new_method']
var taxa = $feature['Taxa']
var filterStatement_geo = "Latitude = @point_lat AND Longitude = @point_long AND new_method = @method AND Taxa = @taxa"
var lay_geo = Filter($layer, filterStatement_geo)
// lay_geo has the points that correspond to the selected point.

var all_species = []
var all_dates = []
for (var f in lay_geo) {
    var sp_name = f.Genus +" "+ f.Species
    all_species[Count(all_species)] = sp_name
    all_dates[Count(all_dates)] = f.date_class
    
}
var unique_species = Distinct(all_species)
var nber_individuals = count(lay_geo)
var nber_species = count(unique_species)
var unique_dates = reverse(sort(Distinct(all_dates)))


var date_content = []
if(count(unique_dates) == 1){
    date_content = text(first(unique_dates), 'MMMM D, Y')
}
else{
    for (var d in unique_dates){
        
        date_content[Count(date_content)] = text(unique_dates[d], 'D')
        if (Count(date_content) == count(unique_dates)){
            date_content[Count(date_content)-1] = text(unique_dates[d], 'D MMMM Y')
        }
    }
}
var date_concat = concatenate(date_content,", ")




var content = "On "+ date_concat + ", in this location, " + nber_individuals + " individuals were caught with a " + method + ". Up to " + nber_species + " species of dung beetles were identified."

return content
// In this point [nber_individuals] individuals were caught with [method] tool. 
// Up to xx species were identified of dungbeetle/bat/small mammal 
// on 21/03/2013

```