library(sandwich)
library(lmtest)
library(car)


data = read.csv("C:/Users/colep/Downloads/HCA_Project/my_data.csv")

# set reference categories
data$geographic_region <- relevel(factor(data$geographic_region), ref = 'south')
data$insurance_type    <- relevel(factor(data$insurance_type), ref = 'public')
data$race              <- relevel(factor(data$race), ref = 'white')
data$income_category   <- factor(data$income_category, 
                                 levels = c('poor','near-poor','low','middle','high'))
data$therapeutic_class <- relevel(factor(data$therapeutic_class), ref = 'other')

# baseline is poor white female,
# public insurance from the south,
# paying other class of drugs,
# with no chronic conditions

model = lm(out_pocket_payment ~ 
     age +
     sex +
     race +
     insurance_type +
     income_category +
     geographic_region +
     therapeutic_class +
     high_bp +
     diabetes +
     heart_disease +
     asthma,
   data = data)


# clustered standard errors by person
coeftest(model, vcov = vcovCL(model, cluster = ~patient_id))

vif(model)



