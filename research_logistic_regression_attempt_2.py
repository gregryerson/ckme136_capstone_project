
# coding: utf-8

# In[8]:

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


# In[9]:

plt.style.use('ggplot') # graph style


# In[10]:

# connect to postgresql database
engine = create_engine ('postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo')


# In[11]:

# create initial data frame for model
dataset = pd.read_sql_query("SELECT ticketed, municipality, ward_id, ward_name, geo_id, feature_code,                              month, season, parking_ticket_rank, parking_tickets, tickets_nearby                              FROM address_monthly_rank;", engine)

dataset.head()


# In[12]:

# Initialize label encoder
label_encoder = preprocessing.LabelEncoder()

# use label encoding to convert nominal/ordinal data to numeric format
encoded_municipality = label_encoder.fit_transform(dataset['municipality'])
encoded_ward_id = label_encoder.fit_transform(dataset['ward_id'])
encoded_geo_id = label_encoder.fit_transform(dataset['geo_id'])
encoded_month = label_encoder.fit_transform(dataset['month'])
encoded_season = label_encoder.fit_transform(dataset['season'])
encoded_feature_code = label_encoder.fit_transform(dataset['feature_code'])
encoded_parking_ticket_rank = label_encoder.fit_transform(dataset['parking_ticket_rank'])


# In[15]:

# create dataset for modeling
# merge and transpose encoded data with continuous data from original dataframe

model_features = pd.DataFrame([dataset['ticketed'], encoded_municipality, encoded_ward_id, encoded_geo_id,                                encoded_feature_code, encoded_month, encoded_season, encoded_parking_ticket_rank,                                dataset['parking_tickets'], dataset['tickets_nearby']]).T

# rename columns
model_features.columns = ['ticketed', 'municipality', 'ward_id', 'geo_id', 'feature_code', 'month', 'season',                           'parking_ticket_rank', 'parking_tickets', 'tickets_nearby']

model_features.head()


# In[16]:

# create dataframes with an intercept column and all other independent variables

y, X = dmatrices('ticketed ~ municipality + ward_id + geo_id + feature_code + month + season + parking_ticket_rank +                   parking_tickets + tickets_nearby', model_features, return_type= 'dataframe')


# In[17]:

# flatten y into a 1-D array so that scikit-learn will properly understand it as the response variable.
y = np.ravel(y)


# In[18]:

# initiate logistic regression model, and fit with X (independent variables print X.columns)and y (ticketed = t/f)
model = LogisticRegression()

# train the model
model = model.fit(X, y)

# check the accuracy on the training set
model.score(X, y)


# an 86% accuracy was observed utilizing all variables within model

# In[20]:

# what percentage had affairs?
y.mean()


# Only 31% of the addresses were ticketed. This means that you could obtain 69% accuracy by always predicting "no".

# In[21]:

# examine the coefficients
pd.DataFrame(zip(X.columns, np.transpose(model.coef_)))


# Based on earlier analysis, as expected the municipality in which the address is located along with the number of tickets an address is issued, increases the probability of being issued a ticket in the future.
# 
# The feature code (i.e. Low Density Residential,  High Density Residential – Apartment, etc...) also impacts the likelihood of a ticket being issued. 

# In[25]:

# evaluate the model by splitting into train and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)
model2 = LogisticRegression()
model2.fit(X_train, y_train)


# In[26]:

# predict class labels for the test set
predicted = model2.predict(X_test)
print predicted


# In[27]:

# generate class probabilities
probs = model2.predict_proba(X_test)
print probs


# the classifier is predicting a 1 (parking ticket issued) any time the probability in the second column is greater than 0.5.

# In[29]:

# generate evaluation metrics
print metrics.accuracy_score(y_test, predicted)
print metrics.roc_auc_score(y_test, probs[:, 1])


# The accuracy is 76%, which is lower than training and predicting on the original dataset.
# Given that area under ROC (receiver operator characteristic) measures discrimination, that is, the ability of the test to correctly classify addresses with and without parking tickets. The ROC curve is 74%, this indicates that the model does an average job at classifying addresses between ticketed and non-ticketed.

# In[30]:

print metrics.confusion_matrix(y_test, predicted)
print metrics.classification_report(y_test, predicted)


# when analyzing the confusion matrix, we see that the model was slightly better at predicting non-ticketed address versus ticketed addresses. 
# 
# similar to the precision score, recall rates were much higher for non-ticketed addresses (94% versus 38%)
# 
# f1-score takes into account the failures in accurately predicting ticketed addresses.

# In[39]:

# evaluate the model using 10-fold cross-validation
scores = cross_val_score(LogisticRegression(), X, y, scoring='accuracy', cv=10)
print scores
print scores.mean()


# In[31]:

from sklearn.feature_selection import RFE
from sklearn.linear_model import LogisticRegression


# In[32]:

# separate dependent / independent variables
x = model_features[['municipality', 'ward_id', 'geo_id', 'feature_code', 'month', 'season', 'parking_ticket_rank',                     'parking_tickets', 'tickets_nearby']].as_matrix()

y = np.ravel(model_features[['ticketed']])
columns = ['municipality', 'ward_id', 'geo_id', 'month', 'parking_tickets', 'tickets_nearby']


# In[34]:

# create a base classifier used to evaluate a subset of attributes
rfe_model = LogisticRegression()


# In[37]:

#rank all features, i.e continue the elimination until the last one
rfe = RFE(rfe_model, n_features_to_select=1)
rfe.fit(x,y)


# In[38]:

# summarize the selection of the attributes
print(rfe.support_)
print(rfe.ranking_)


# RFE ranking : parking_tickets, municipality, season, month, ward_id, feature_code, parking_ticket_rank, tickets_nearby, geo_id

# In[40]:

from sklearn.linear_model import RandomizedLasso


# In[41]:

# intialize randomized lasso
rlasso = RandomizedLasso(alpha=0.025)
rlasso.fit(x, y)

print "Features sorted by their score:"
print sorted(zip(map(lambda x: round(x, 4), rlasso.scores_), 
                 columns), reverse=True)


# In[42]:

from sklearn.ensemble import ExtraTreesClassifier


# In[43]:

tree_model = ExtraTreesClassifier()
tree_model.fit(x, y)
# display the relative importance of each attribute
print(tree_model.feature_importances_)


# ranking : parking_tickets (0.39), parking_ticket_rank (0.30), municipality (0.12), ward_id (0.10), geo_id (0.04), tickets_nearby (0.01), season (0.01), month (0.01), feature_code (0.01)
# 
# The extra trees classifier scores both parking_tickets and parking_ticket_rank very highly. Given that there is an inverse relationship between these variables, this should come as no surpirse. Similar to the RFE model that was run, municipality and ward both rank highly. the difference between the two feature selection methods is that season and month are ranked lower within the extra trees classifier.
