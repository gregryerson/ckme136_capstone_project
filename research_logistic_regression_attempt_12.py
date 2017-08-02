
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


# In[4]:

dataset = pd.read_csv('/Volumes/Seagate Backup Plus Drive/ckme136_capstone_project/toronto parking tickets/address_monthly_rank.csv')

print 'removing unnecessary columns...'
dataset = dataset[['geo_id', 'ticketed', 'municipality', 'ward_id', 'month', 'season', 'parking_tickets', 'parking_ticket_rank']]

dataset.head()


# In[5]:

# convert ticketed from boolean to integer
dataset['ticketed'] = dataset['ticketed'].map({'t':1, 'f':0})
dataset['ticketed'] = dataset['ticketed'].astype(int)


# In[6]:

dataset.head()


# In[7]:

# create ordinal data utilizing parking ticket rank
# 0 being the lowest ranking and 4 being the highest

dataset['parking_ticket_ordinal'] = 0
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 100] = 1
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 50] = 2
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 25] = 3
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 10] = 4
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] == 0] = 0

dataset.head()


# In[13]:

# create a combination of label encoding and dummy variables
# Initialize label encoders
label_encoder = preprocessing.LabelEncoder()

# use label encoding to convert nominal/ordinal data to numeric format
encoded_parking_ticket_ordinal = label_encoder.fit_transform(dataset['parking_ticket_ordinal'])

dummy_municipality = pd.get_dummies(dataset['municipality'], drop_first= True, prefix = 'municipality') # east york dropped
dummy_month = pd.get_dummies(dataset['month'], drop_first= True, prefix = 'month') # month_1 (jan) dropped
dummy_season = pd.get_dummies(dataset['season'], drop_first= True, prefix = 'season') # fall dropped


# In[14]:

dummy_municipality.rename(columns={'municipality_North York':'municipality_North_York'}, inplace= True)
dummy_municipality.head() # east york dropped


# In[15]:

dummy_month.head() # 1 (jan) dropped


# In[16]:

dummy_season.head() # fall dropped


# In[17]:

# create dataset for modeling
# merge and transpose encoded data with continuous data from original dataframe

model_features = pd.DataFrame([dataset['ticketed'], encoded_parking_ticket_ordinal]).T
print 'transpose complete...'

# rename columns
model_features.columns = ['ticketed', 'parking_ticket_ordinal']

# join categorical dummy variables data frames

print 'joining dummy variables...'
model_features = model_features.join(dummy_municipality)
model_features = model_features.join(dummy_month)
model_features = model_features.join(dummy_season)

model_features.head()


# In[19]:

# create dataframes with an intercept column and all other independent variables

y, X = dmatrices('ticketed ~ parking_ticket_ordinal + municipality_Etobicoke + municipality_North_York                   + municipality_Scarborough + municipality_Toronto + municipality_York + month_2 + month_3                   + month_4 + month_5 + month_6 + month_7 + month_8 + month_9 + month_10 + month_11 + month_12                   + season_Spring + season_Summer + season_Winter'                  , model_features, return_type= 'dataframe')


# In[20]:

# flatten y into a 1-D array so that scikit-learn will properly understand it as the response variable.
y = np.ravel(model_features['ticketed'])


# In[21]:

# initiate logistic regression model, and fit with X (independent variables print X.columns)and y (ticketed = t/f)
model = LogisticRegression()

# train the model
model = model.fit(X, y)

# check the accuracy on the training set
model.score(X, y)


# an 74% accuracy was observed utilizing all variables within model

# In[22]:

# examine the coefficients
pd.DataFrame(zip(X.columns, np.transpose(model.coef_)))


# Replacing parking tickets with categorization a heavier importance to the ordinal values (moreso than in the day of week model). As with other models, we see that being in the municipality_Toronto increases the odds of being issued a parking ticket. Interestingly enough, as seen in the analysis trying to your chances of being issued a ticket increase in June and December. 

# In[23]:

# evaluate the model by splitting into train and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)
model2 = LogisticRegression()
model2.fit(X_train, y_train)


# In[24]:

# predict class labels for the test set
predicted = model2.predict(X_test)
print predicted


# In[25]:

# generate class probabilities
probs = model2.predict_proba(X_test)
print probs


# the classifier is predicting a 1 (parking ticket issued) any time the probability in the second column is greater than 0.5.

# In[26]:

# generate evaluation metrics
print metrics.accuracy_score(y_test, predicted)
print metrics.roc_auc_score(y_test, probs[:, 1])


# The accuracy is 74%, which is the same as accuracy score on the original dataset.
# Given that area under ROC (receiver operator characteristic) measures discrimination, that is, the ability of the test to correctly classify addresses with and without parking tickets. The ROC curve is 73%, this indicates that the model does an below average job at classifying addresses between ticketed and non-ticketed. These are slight improvements over the day of week models. 

# In[38]:

print metrics.confusion_matrix(y_test, predicted)
print metrics.classification_report(y_test, predicted)


# when analyzing the confusion matrix, as in previous models we see that the model was significantly better at predicting non-ticketed address versus ticketed addresses. 
# 
# similar to the precision score, recall rates were much higher for non-ticketed addresses (80% versus 58%). While we saw an increase in accuracy, the precision score for predicting parking tickets decreased versus the day of week model.

# In[28]:

# evaluate the model using 10-fold cross-validation
scores = cross_val_score(LogisticRegression(), X, y, scoring='accuracy', cv=10)
print scores
print scores.mean()


# In[29]:

from sklearn.feature_selection import RFE
from sklearn.linear_model import LogisticRegression


# In[30]:

# separate dependent / independent variables
x = model_features[['parking_ticket_ordinal', 'municipality_Etobicoke', 'municipality_North_York',                   'municipality_Scarborough', 'municipality_Toronto', 'municipality_York', 'month_2', 'month_3',                   'month_4', 'month_5', 'month_6', 'month_7', 'month_8', 'month_9', 'month_10', 'month_11',                   'month_12', 'season_Spring', 'season_Summer', 'season_Winter']].as_matrix()

y = np.ravel(model_features[['ticketed']])
columns = ['parking_ticket_ordinal', 'municipality_Etobicoke', 'municipality_North_York',            'municipality_Scarborough', 'municipality_Toronto', 'municipality_York', 'month_2', 'month_3',            'month_4', 'month_5', 'month_6', 'month_7', 'month_8', 'month_9', 'month_10', 'month_11',            'month_12', 'season_Spring', 'season_Summer', 'season_Winter']


# In[31]:

# create a base classifier used to evaluate a subset of attributes
rfe_model = LogisticRegression()


# In[32]:

#rank all features, i.e continue the elimination until the last one
rfe = RFE(rfe_model, n_features_to_select=1)
rfe.fit(x,y)


# In[33]:

# summarize the selection of the attributes
print(rfe.support_)
print(rfe.ranking_)


# RFE ranking : parking_ticket_ordinal, municipality_North_York, municipality_Scarborough, municipality_Etobicoke, municipality_York, municipality_Toronto, month_2, month_3, month_10, season_Winter, month_5, month_6, month_8, month_12, season_Spring, month_7, month_4, season_Summer, month_11, month_9

# In[34]:

from sklearn.linear_model import RandomizedLasso


# In[35]:

# intialize randomized lasso
rlasso = RandomizedLasso(alpha=0.025)
rlasso.fit(x, y)

print "Features sorted by their score:"
print sorted(zip(map(lambda x: round(x, 4), rlasso.scores_), 
                 columns), reverse=True)


# In[36]:

from sklearn.ensemble import ExtraTreesClassifier


# In[37]:

tree_model = ExtraTreesClassifier()
tree_model.fit(x, y)
# display the relative importance of each attribute
print(tree_model.feature_importances_)


# ranking : municipality_Toronto : (0.5624), municipality_Scarborough : (0.1303), parking_ticket_ordinal : (0.1285)
# municipality_North_York : (0.0901), municipality_Etobicoke : (0.0578), municipality_York : (0.0152), season_Winter : (0.0063), month_3 : (0.0022), month_12 : (0.0019), month_2 : (0.0017), month_5 : (0.0005), season_Summer : (0.0005) month_9 : (0.0004), month_10 : (0.0004), month_11 : (0.0004), season_Spring : (0.0003), month_6 : (0.0003), month_4 : (0.0003), month_8 : (0.0003), month_7 : (0.0001)
# 
# As with the previous models, the extra trees classifier produces results which are different than what was produced in the RFE simulation as it has assigned a larger weigthing to the municipalities. The only difference here is that parking_ticket_ordinal is ranked in between the municipalities versus after them. 
# 
# In the next simulation, we will only use the following variables: municipality_Toronto, municipality_Scarborough, municipality_North_York, municipality_Etobicoke, parking_ticket_ordinal
