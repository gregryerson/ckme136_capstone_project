
# coding: utf-8

# In[1]:

from patsy import dmatrices
from sklearn import linear_model
from sklearn import preprocessing
from sklearn.linear_model import LogisticRegression
from sklearn.cross_validation import train_test_split
from sklearn import metrics
from sklearn.cross_validation import cross_val_score
from sqlalchemy import create_engine

import matplotlib.pyplot as plt
import matplotlib.ticker as tkr
import numpy as np
import pandas as pd
import psycopg2
import scipy.stats as stats
import statsmodels.api as sm


# In[2]:

plt.style.use('ggplot') # graph style


# In[3]:

# connect to postgresql database
engine = create_engine ('postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo')


# In[4]:

# create initial data frame for model
dataset = pd.read_sql_query("SELECT ticketed, municipality, ward_id, ward_name, geo_id, feature_code,                              address_class_descr, month, season, dayofweek, weekend, parking_tickets                              FROM address_monthly_dow_rank;", engine)

dataset.head()


# In[2]:

# a combination of label and one hot encoding will be used
# Initialize label encoders
label_encoder = preprocessing.LabelEncoder()

# use label encoding to convert nominal/ordinal data to numeric format
dummy_municipality = pd.get_dummies(dataset['municipality'], drop_first= True, prefix = 'municipality') # east york dropped
print 'dummy_municipality complete!' 

encoded_ward_id = label_encoder.fit_transform(dataset['ward_id'])
print 'encoded_ward_id complete!' 

encoded_geo_id = label_encoder.fit_transform(dataset['geo_id'])
print 'encoded_geo_id complete!' 

encoded_feature_code = label_encoder.fit_transform(dataset['feature_code'])
print 'encoded_geo_id complete!' 

encoded_address_class_descr = label_encoder.fit_transform(dataset['address_class_descr'])
print 'address_class_descr complete!' 

dummy_month = pd.get_dummies(dataset['month'], drop_first= True, prefix = 'month') # month_1 (jan) dropped
print 'dummy_month complete!' 

dummy_season = pd.get_dummies(dataset['season'], drop_first= True, prefix = 'season') # fall dropped
print 'dummy_season complete!' 

dummy_dayofweek = pd.get_dummies(dataset['dayofweek'], drop_first= True, prefix = 'dow') # 0 - sunday dropped
print 'dummy_dayofweek complete!' 

dummy_weekend = pd.get_dummies(dataset['weekend'], drop_first= True, prefix = 'weekend') # fall dropped
print 'dummy_weekend complete!' 

encoded_parking_ticket_rank = label_encoder.fit_transform(dataset['parking_ticket_rank'])
print 'encoded_parking_ticket_rank complete!' 


# In[6]:

dummy_municipality.rename(columns={'municipality_North York':'municipality_North_York'}, inplace=True)
dummy_municipality.head() # east york dropped


# In[7]:

dummy_month.head() # month_1 (jan) dropped


# In[8]:

dummy_season.head() # fall dropped


# In[9]:

dummy_dayofweek.head() # 0 - sunday dropped


# In[10]:

dummy_weekend.head() # false - weekday dropped


# In[11]:

# create dataset for modeling
# merge and transpose encoded data with continuous data from original dataframe

model_features = pd.DataFrame([dataset['ticketed'], encoded_ward_id, encoded_geo_id, encoded_feature_code,
                              encoded_address_class_descr, encoded_parking_ticket_rank]).T


# rename columns
model_features.columns = ['ticketed', 'ward_id', 'geo_id', 'feature_code', 'address_class_descr',                           'parking_ticket_rank']

# join categorical dummy variables data frames

model_features = model_features.join(dummy_municipality)
model_features = model_features.join(dummy_month)
model_features = model_features.join(dummy_season)
model_features = model_features.join(dummy_dayofweek)
model_features = model_features.join(dummy_weekend)

#reorder_columns = ['ticketed', 'municipality_Etobicoke','municipality_North_York', 'municipality_Scarborough', \
#                   'municipality_York', 'ward_id', 'geo_id', 'feature_code', 'address_class_descr', \
#                   'month_2', 'month_3', 'month_4', 'month_5', 'month_6', 'month_7', 'month_8', 'month_9', \
#                   'month_10','month_11', 'month_12', 'season_Spring', 'season_Summer', 'season_Winter', \
#                   'dow_1', 'dow_2','dow_3', 'dow_4', 'dow_5', 'dow_6', 'weekend_True', 'parking_ticket_rank']


#model_features = model_features[reorder_columns]
model_features.head()


# In[12]:

# create dataframes with an intercept column and all other independent variables

y, X = dmatrices('ticketed ~ municipality_Etobicoke + municipality_North_York + municipality_Scarborough                  + municipality_Toronto + municipality_York + ward_id + geo_id + feature_code + address_class_descr                  + month_2 + month_3 + month_4 + month_5 + month_6 + month_7 + month_8 + month_9 + month_10                  + month_11 + month_12 + season_Spring + season_Summer + season_Winter + dow_1 + dow_2 + dow_3                  + dow_4 + dow_5 + dow_6 + weekend_True + parking_ticket_rank'                  ,model_features, return_type= 'dataframe')


# In[13]:

# flatten y into a 1-D array so that scikit-learn will properly understand it as the response variable.
y = np.ravel(y)


# In[14]:

# initiate logistic regression model, and fit with X (independent variables print X.columns)and y (ticketed = t/f)
model = LogisticRegression()

# train the model
model = model.fit(X, y)

# check the accuracy on the training set
model.score(X, y)


# an 88% accuracy was observed utilizing all variables within model

# In[15]:

# what percentage were ticketed?
y.mean()


# Only 11% of the addresses were ticketed. This means that you could obtain 89% accuracy by always predicting "no".

# In[1]:

# examine the coefficients
pd.DataFrame(zip(X.columns, np.transpose(model.coef_)))


# This is the point where the kernel restarted.
