
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


# In[8]:

# create a combination of label encoding and dummy variables
# Initialize label encoders
label_encoder = preprocessing.LabelEncoder()

# use label encoding to convert nominal/ordinal data to numeric format
encoded_parking_ticket_ordinal = label_encoder.fit_transform(dataset['parking_ticket_ordinal'])

dummy_municipality = pd.get_dummies(dataset['municipality'], drop_first= True, prefix = 'municipality') # east york dropped


# In[9]:

dummy_municipality.rename(columns={'municipality_North York':'municipality_North_York'}, inplace= True)
dummy_municipality = dummy_municipality[['municipality_Etobicoke', 'municipality_North_York',                                          'municipality_Scarborough', 'municipality_Toronto']] 
dummy_municipality.head() # east york dropped, york dropped (as per reco in attempt 12)


# In[10]:

# create dataset for modeling
# merge and transpose encoded data with continuous data from original dataframe

model_features = pd.DataFrame([dataset['ticketed'], encoded_parking_ticket_ordinal]).T
print 'transpose complete...'

# rename columns
model_features.columns = ['ticketed', 'parking_ticket_ordinal']

# join categorical dummy variables data frames

print 'joining dummy variables...'
model_features = model_features.join(dummy_municipality)

model_features.head()


# In[11]:

# create dataframes with an intercept column and all other independent variables

y, X = dmatrices('ticketed ~ parking_ticket_ordinal + municipality_Etobicoke + municipality_North_York                   + municipality_Scarborough + municipality_Toronto'                  , model_features, return_type= 'dataframe')


# In[12]:

# flatten y into a 1-D array so that scikit-learn will properly understand it as the response variable.
y = np.ravel(y)


# In[13]:

# initiate logistic regression model, and fit with X (independent variables print X.columns)and y (ticketed = t/f)
model = LogisticRegression()

# train the model
model = model.fit(X, y)

# check the accuracy on the training set
model.score(X, y)


# an 74% accuracy was observed utilizing all variables within model

# In[14]:

y.mean()


# In[15]:

# examine the coefficients
pd.DataFrame(zip(X.columns, np.transpose(model.coef_)))


# In comparison to the results in attempt 12, we see a reduction in the intercept and parking_ticket_ordinal variables while seeing a heavier weighting for addresses in the municipality of Toronto.

# In[16]:

# evaluate the model by splitting into train and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)
model2 = LogisticRegression()
model2.fit(X_train, y_train)


# In[17]:

# predict class labels for the test set
predicted = model2.predict(X_test)
print predicted


# In[18]:

# generate class probabilities
probs = model2.predict_proba(X_test)
print probs


# the classifier is predicting a 1 (parking ticket issued) any time the probability in the second column is greater than 0.5.

# In[19]:

# generate evaluation metrics
print metrics.accuracy_score(y_test, predicted)
print metrics.roc_auc_score(y_test, probs[:, 1])


# Almost near identical results to the previous attempt. The accuracy is 73%, which is the same as accuracy score on the original dataset.
# Given that area under ROC (receiver operator characteristic) measures discrimination, that is, the ability of the test to correctly classify addresses with and without parking tickets. The ROC curve is 72%, this indicates that the model does an below average job at classifying addresses between ticketed and non-ticketed. These are slight improvements over the day of week models. 

# In[32]:

print metrics.confusion_matrix(y_test, predicted)
print metrics.classification_report(y_test, predicted)


# interestingly, identical results with the previous attempt.

# In[33]:

# evaluate the model using 10-fold cross-validation
scores = cross_val_score(LogisticRegression(), X, y, scoring='accuracy', cv=10)
print scores
print scores.mean()


# In[22]:

from sklearn.feature_selection import RFE
from sklearn.linear_model import LogisticRegression


# In[24]:

# separate dependent / independent variables
x = model_features[['parking_ticket_ordinal', 'municipality_Etobicoke', 'municipality_North_York',                   'municipality_Scarborough', 'municipality_Toronto']].as_matrix()

y = np.ravel(model_features[['ticketed']])
columns = ['parking_ticket_ordinal', 'municipality_Etobicoke', 'municipality_North_York',            'municipality_Scarborough', 'municipality_Toronto']


# In[25]:

# create a base classifier used to evaluate a subset of attributes
rfe_model = LogisticRegression()


# In[26]:

#rank all features, i.e continue the elimination until the last one
rfe = RFE(rfe_model, n_features_to_select=1)
rfe.fit(x,y)


# In[27]:

# summarize the selection of the attributes
print(rfe.support_)
print(rfe.ranking_)


# RFE ranking : parking_ticket_ordinal, municipality_Scarborough, municipality_Toronto, municipality_North_York, municipality_Etobicoke

# In[28]:

from sklearn.linear_model import RandomizedLasso


# In[29]:

# intialize randomized lasso
rlasso = RandomizedLasso(alpha=0.025)
rlasso.fit(x, y)

print "Features sorted by their score:"
print sorted(zip(map(lambda x: round(x, 4), rlasso.scores_), 
                 columns), reverse=True)


# In[30]:

from sklearn.ensemble import ExtraTreesClassifier


# In[31]:

tree_model = ExtraTreesClassifier()
tree_model.fit(x, y)
# display the relative importance of each attribute
print(tree_model.feature_importances_)


# ranking : municipality_Toronto : (0.4547), municipality_Scarborough : (0.1967), parking_ticket_ordinal : (0.1353)
# municipality_Etobicoke : (0.1244), municipality_North_York : (0.09)
# 
# As with the previous models, the extra trees classifier produces results which are different than what was produced in the RFE simulation as it has assigned a larger weigthing to the municipalities. The only difference here is that parking_ticket_ordinal is ranked in between the municipalities versus after them. 
