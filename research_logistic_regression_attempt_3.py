
# coding: utf-8

# In[2]:

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


# In[3]:

plt.style.use('ggplot') # graph style


# In[4]:

# connect to postgresql database
engine = create_engine ('postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo')


# based on findings from attempt 2
# kept municipality, season, month, ward_id, geo_id, given that the parking ticket coefficient was very high in attempt 2. it was removed to see what impact it had on the model.

# In[5]:

# create initial data frame for model
dataset = pd.read_sql_query("SELECT ticketed, municipality, ward_id, geo_id, month, season, parking_tickets                              FROM address_monthly_rank;", engine)

dataset.head()


# In[15]:

# a combination of label and one hot encoding will be used
# Initialize label encoders
label_encoder = preprocessing.LabelEncoder()
onehot_encoder = OneHotEncoder(sparse=False)

# use label encoding to convert nominal/ordinal data to numeric format
encoded_ward_id = label_encoder.fit_transform(dataset['ward_id'])
encoded_geo_id = label_encoder.fit_transform(dataset['geo_id'])

dummy_municipality = pd.get_dummies(dataset['municipality'], drop_first= True, prefix = 'municipality') # east york dropped
dummy_month = pd.get_dummies(dataset['month'], drop_first= True, prefix = 'month') # month_1 (jan) dropped
dummy_season = pd.get_dummies(dataset['season'], drop_first= True, prefix = 'season') # fall dropped


# In[22]:

dummy_municipality.rename(columns={'municipality_North York':'municipality_North_York'}, inplace=True)
dummy_municipality.head() # east york dropped


# In[19]:

dummy_month.head() # month_1 (jan) dropped


# In[20]:

dummy_season.head() # fall dropped


# In[25]:

# create dataset for modeling
# merge and transpose encoded data with continuous data from original dataframe

model_features = pd.DataFrame([dataset['ticketed'], encoded_ward_id, encoded_geo_id]).T

# rename columns
model_features.columns = ['ticketed', 'ward_id', 'geo_id']

# join categorical dummy variables data frames

model_features = model_features.join(dummy_municipality)
model_features = model_features.join(dummy_month)
model_features = model_features.join(dummy_season)

model_features.head()


# In[26]:

# create dataframes with an intercept column and all other independent variables

y, X = dmatrices('ticketed ~ ward_id + geo_id + municipality_Etobicoke + municipality_North_York                   + municipality_Scarborough + municipality_Toronto + municipality_York + month_2 + month_3 + month_4                   + month_5 + month_6 + month_7 + month_8 + month_9 + month_10 + month_11 + month_12                   + season_Spring + season_Summer + season_Winter'                 , model_features, return_type= 'dataframe')


# In[27]:

# flatten y into a 1-D array so that scikit-learn will properly understand it as the response variable.
y = np.ravel(y)


# In[28]:

# initiate logistic regression model, and fit with X (independent variables print X.columns)and y (ticketed = t/f)
model = LogisticRegression()

# train the model
model = model.fit(X, y)

# check the accuracy on the training set
model.score(X, y)


# an 69% accuracy was observed utilizing all variables within model

# In[30]:

# what percentage were issued tickets?
y.mean()


# Only 31% of the addresses were ticketed. This means that you could obtain 69% accuracy by always predicting "no".

# In[31]:

# examine the coefficients
pd.DataFrame(zip(X.columns, np.transpose(model.coef_)))


# Based on earlier analysis, given that the city of Toronto represents over 70% of tickets issued, it is expected to be a factor within our model. While small, it is the only coefficient that increases the probability of receiving a parking ticket. Although geo_id has a negative coefficient, given that the geo_id begins at 16445 and ends at 30094902, it would suggest that the geo id has a significant impact on the model. 

# In[32]:

# evaluate the model by splitting into train and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)
model2 = LogisticRegression()
model2.fit(X_train, y_train)


# In[33]:

# predict class labels for the test set
predicted = model2.predict(X_test)
print predicted


# In[34]:

# generate class probabilities
probs = model2.predict_proba(X_test)
print probs


# the classifier is predicting a 1 (parking ticket issued) any time the probability in the second column is greater than 0.5.

# In[35]:

# generate evaluation metrics
print metrics.accuracy_score(y_test, predicted)
print metrics.roc_auc_score(y_test, probs[:, 1])


# The accuracy is 69%, which is the same as accuracy score on the original dataset.
# Given that area under ROC (receiver operator characteristic) measures discrimination, that is, the ability of the test to correctly classify addresses with and without parking tickets. The ROC curve is 52%, this indicates that the model does an below average job at classifying addresses between ticketed and non-ticketed.

# In[36]:

print metrics.confusion_matrix(y_test, predicted)
print metrics.classification_report(y_test, predicted)


# In[37]:

# evaluate the model using 10-fold cross-validation
scores = cross_val_score(LogisticRegression(), X, y, scoring='accuracy', cv=10)
print scores
print scores.mean()


# In[38]:

from sklearn.feature_selection import RFE
from sklearn.linear_model import LogisticRegression


# In[40]:

# separate dependent / independent variables
x = model_features[['ward_id', 'geo_id', 'municipality_Etobicoke', 'municipality_North_York',                   'municipality_Scarborough', 'municipality_Toronto','municipality_York', 'month_2', 'month_3',
                  'month_4', 'month_5', 'month_6', 'month_7', 'month_8', 'month_9', 'month_10', 'month_11', \
                  'month_12', 'season_Spring', 'season_Summer', 'season_Winter']].as_matrix()

y = np.ravel(model_features[['ticketed']])
columns = ['ward_id', 'geo_id', 'municipality_Etobicoke', 'municipality_North_York',                   'municipality_Scarborough', 'municipality_Toronto','municipality_York', 'month_2', 'month_3',
                  'month_4', 'month_5', 'month_6', 'month_7', 'month_8', 'month_9', 'month_10', 'month_11', \
                  'month_12', 'season_Spring', 'season_Summer', 'season_Winter']


# In[41]:

# create a base classifier used to evaluate a subset of attributes
rfe_model = LogisticRegression()


# In[42]:

#rank all features, i.e continue the elimination until the last one
rfe = RFE(rfe_model, n_features_to_select=1)
rfe.fit(x,y)


# In[43]:

# summarize the selection of the attributes
print(rfe.support_)
print(rfe.ranking_)


# RFE ranking : 1. municipality_Scarborough, 2. municipality_Etobicoke, 3. municipality_North_York, 4. municipality_York, 5. municipality_York, 6. month_2, 7. month_3, 8. month_12, 9. month_6, 10. season_Spring

# In[44]:

from sklearn.linear_model import RandomizedLasso


# In[45]:

# intialize randomized lasso
rlasso = RandomizedLasso(alpha=0.025)
rlasso.fit(x, y)

print "Features sorted by their score:"
print sorted(zip(map(lambda x: round(x, 4), rlasso.scores_), 
                 columns), reverse=True)


# In[46]:

from sklearn.ensemble import ExtraTreesClassifier


# In[47]:

tree_model = ExtraTreesClassifier()
tree_model.fit(x, y)
# display the relative importance of each attribute
print(tree_model.feature_importances_)


# ranking : geo_id: (0.8346), municipality_Toronto: (0.062), ward_id: (0.0396), municipality_North_York: (0.0226), municipality_Scarborough: (0.019), municipality_Etobicoke: (0.0175), season_Winter: (0.0014), municipality_York: (0.0013), month_3: (0.0005), month_2: (0.0003), month_12: (0.0003), season_Summer: (0.0001), month_5: (0.0001), month_4: (0.0001), month_10: (0.0001), season_Spring: (0.0001), month_6: (0.0001), month_9: (0.0001), month_11: (0.0001), month_7: (0), month_8: (0)
