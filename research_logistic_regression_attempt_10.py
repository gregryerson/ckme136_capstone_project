
# coding: utf-8

# due to the disadvantages of label encoding each categorical variable, a mixture of label encoding and dummy variables will be used for this attempt...

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


# In[33]:

dataset = pd.read_csv('/Volumes/Seagate Backup Plus Drive/ckme136_capstone_project/toronto parking tickets/address_dow_rank.csv')

print 'removing unnecessary columns...'
dataset = dataset[['ticketed', 'municipality', 'ward_id', 'dayofweek', 'weekend', 'parking_tickets', 'parking_ticket_rank']]

dataset.head()


# In[34]:

# convert ticketed from boolean to integer
dataset['ticketed'] = dataset['ticketed'].map({'t':1, 'f':0})
dataset['ticketed'] = dataset['ticketed'].astype(int)


# In[35]:

dataset.head()


# In[36]:

# create ordinal data utilizing parking ticket rank
# 0 being the lowest ranking and 4 being the highest

dataset['parking_ticket_ordinal'] = 0
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 100] = 1
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 50] = 2
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 25] = 3
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 10] = 4
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] == 0] = 0

dataset.head()


# In[37]:

# create a combination of label encoding and dummy variables
# Initialize label encoders
label_encoder = preprocessing.LabelEncoder()

# use label encoding to convert nominal/ordinal data to numeric format
encoded_parking_ticket_ordinal = label_encoder.fit_transform(dataset['parking_ticket_ordinal'])

dummy_municipality = pd.get_dummies(dataset['municipality'], drop_first= True, prefix = 'municipality') # east york dropped
dummy_dayofweek = pd.get_dummies(dataset['dayofweek'], drop_first= True, prefix = 'dow') # month_1 (jan) dropped
dummy_weekend = pd.get_dummies(dataset['weekend'], drop_first= True, prefix = 'weekend') # fall dropped


# In[38]:

dummy_municipality.rename(columns={'municipality_North York':'municipality_North_York'}, inplace= True)
dummy_municipality.head() # east york dropped


# In[39]:

dummy_dayofweek.head() # 0 (sun) dropped


# In[40]:

dummy_weekend.head() # fall dropped


# In[41]:

# create dataset for modeling
# merge and transpose encoded data with continuous data from original dataframe

model_features = pd.DataFrame([dataset['ticketed'], encoded_parking_ticket_ordinal]).T
print 'transpose complete...'

# rename columns
model_features.columns = ['ticketed', 'parking_ticket_ordinal']

# join categorical dummy variables data frames

print 'joining dummy variables...'
model_features = model_features.join(dummy_municipality)
model_features = model_features.join(dummy_dayofweek)
model_features = model_features.join(dummy_weekend)

model_features.head()


# In[42]:

# create dataframes with an intercept column and all other independent variables

y, X = dmatrices('ticketed ~ parking_ticket_ordinal + municipality_Etobicoke + municipality_North_York                   + municipality_Scarborough + municipality_Toronto + municipality_York + dow_1 + dow_2 + dow_3                   + dow_4 + dow_5 + dow_6 + weekend_t'                 , model_features, return_type= 'dataframe')


# In[43]:

# flatten y into a 1-D array so that scikit-learn will properly understand it as the response variable.
y = np.ravel(model_features['ticketed'])


# In[44]:

# initiate logistic regression model, and fit with X (independent variables print X.columns)and y (ticketed = t/f)
model = LogisticRegression()

# train the model
model = model.fit(X, y)

# check the accuracy on the training set
model.score(X, y)


# an 71% accuracy was observed utilizing all variables within model

# In[45]:

# examine the coefficients
pd.DataFrame(zip(X.columns, np.transpose(model.coef_)))


# Replacing parking tickets with categorization has given near equal importance to all three ordinal values. As with other models, we see that being in the municipality_Toronto increases the odds of being issued a parking ticket. Interestingly enough, as seen in the analysis trying to your chances of being issued a ticket on Mondays (dow_1) decreases. 

# In[46]:

# evaluate the model by splitting into train and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)
model2 = LogisticRegression()
model2.fit(X_train, y_train)


# In[47]:

# predict class labels for the test set
predicted = model2.predict(X_test)
print predicted


# In[48]:

# generate class probabilities
probs = model2.predict_proba(X_test)
print probs


# the classifier is predicting a 1 (parking ticket issued) any time the probability in the second column is greater than 0.5.

# In[49]:

# generate evaluation metrics
print metrics.accuracy_score(y_test, predicted)
print metrics.roc_auc_score(y_test, probs[:, 1])


# The accuracy is 71%, which is the same as accuracy score on the original dataset.
# Given that area under ROC (receiver operator characteristic) measures discrimination, that is, the ability of the test to correctly classify addresses with and without parking tickets. The ROC curve is 71%, this indicates that the model does an below average job at classifying addresses between ticketed and non-ticketed.

# In[50]:

print metrics.confusion_matrix(y_test, predicted)
print metrics.classification_report(y_test, predicted)


# when analyzing the confusion matrix, we see that the model was significantly better at predicting non-ticketed address versus ticketed addresses. 
# 
# similar to the precision score, recall rates were much higher for non-ticketed addresses (80% versus 58%)
# 
# the accuracy overall is 10% higher than the null error rate which while not great, is an indicator that the model works. 

# In[51]:

# evaluate the model using 10-fold cross-validation
scores = cross_val_score(LogisticRegression(), X, y, scoring='accuracy', cv=10)
print scores
print scores.mean()


# In[52]:

from sklearn.feature_selection import RFE
from sklearn.linear_model import LogisticRegression


# In[53]:

# separate dependent / independent variables
x = model_features[['parking_ticket_ordinal', 'municipality_Etobicoke', 'municipality_North_York',                   'municipality_Scarborough', 'municipality_Toronto', 'municipality_York', 'dow_1', 'dow_2',                   'dow_3', 'dow_4', 'dow_5', 'dow_6', 'weekend_t']].as_matrix()

y = np.ravel(model_features[['ticketed']])
columns = ['parking_ticket_ordinal', 'municipality_Etobicoke', 'municipality_North_York',            'municipality_Scarborough', 'municipality_Toronto', 'municipality_York', 'dow_1', 'dow_2',            'dow_3', 'dow_4', 'dow_5', 'dow_6', 'weekend_t']


# In[54]:

# create a base classifier used to evaluate a subset of attributes
rfe_model = LogisticRegression()


# In[55]:

#rank all features, i.e continue the elimination until the last one
rfe = RFE(rfe_model, n_features_to_select=1)
rfe.fit(x,y)


# In[56]:

# summarize the selection of the attributes
print(rfe.support_)
print(rfe.ranking_)


# RFE ranking : parking_ticket_ordinal, municipality_Scarborough, municipality_North_York, municipality_Toronto, municipality_York, dow_3, dow_4, dow_6, weekend_t, dow_5, dow_2, dow_1

# In[57]:

from sklearn.linear_model import RandomizedLasso


# In[58]:

# intialize randomized lasso
rlasso = RandomizedLasso(alpha=0.025)
rlasso.fit(x, y)

print "Features sorted by their score:"
print sorted(zip(map(lambda x: round(x, 4), rlasso.scores_), 
                 columns), reverse=True)


# In[59]:

from sklearn.ensemble import ExtraTreesClassifier


# In[60]:

tree_model = ExtraTreesClassifier()
tree_model.fit(x, y)
# display the relative importance of each attribute
print(tree_model.feature_importances_)


# ranking : municipality_Toronto : (0.406), municipality_Scarborough : (0.2071), municipality_North_York : (0.1567), municipality_Etobicoke : (0.098), parking_ticket_ordinal : (0.0883), municipality_York : (0.0351), weekend_t : (0.0063), dow_6 : (0.0013), dow_1 : (0.0003), dow_5 : (0.0003), dow_3 : (0.0002), dow_4 : (0.0002), dow_2 : (0)
# 
# The extra trees classifier produces results which are different than what was produced in the RFE simulation as it has assigned a larger weigthing to each municipality and less to parking_ticket_ordinal. 
# 
# In the next simulation, we will only use the following variables: municipality_Toronto, municipality_Scarborough, municipality_North_York, municipality_Etobicoke, parking_ticket_ordinal
