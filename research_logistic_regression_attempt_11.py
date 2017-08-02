
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


# In[34]:

dataset = pd.read_csv('/Volumes/Seagate Backup Plus Drive/ckme136_capstone_project/toronto parking tickets/address_dow_rank.csv')

print 'removing unnecessary columns...'
dataset = dataset[['geo_id', 'ticketed', 'municipality', 'ward_id', 'dayofweek', 'weekend', 'parking_tickets', 'parking_ticket_rank']]

dataset.head()


# In[35]:

# convert ticketed from boolean to integer
dataset['ticketed'] = dataset['ticketed'].map({'t':1, 'f':0})
dataset['ticketed'] = dataset['ticketed'].astype(int)


# In[36]:

dataset.head()


# In[37]:

# create ordinal data utilizing parking ticket rank
# 0 being the lowest ranking and 4 being the highest

dataset['parking_ticket_ordinal'] = 0
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 100] = 1
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 50] = 2
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 25] = 3
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] <= 10] = 4
dataset['parking_ticket_ordinal'][dataset['parking_ticket_rank'] == 0] = 0

dataset.head()


# In[6]:

# create a combination of label encoding and dummy variables
# Initialize label encoders
label_encoder = preprocessing.LabelEncoder()

# use label encoding to convert nominal/ordinal data to numeric format
encoded_parking_ticket_ordinal = label_encoder.fit_transform(dataset['parking_ticket_ordinal'])

dummy_municipality = pd.get_dummies(dataset['municipality'], drop_first= True, prefix = 'municipality') # east york dropped


# In[7]:

dummy_municipality.rename(columns={'municipality_North York':'municipality_North_York'}, inplace= True)
dummy_municipality = dummy_municipality[['municipality_Etobicoke', 'municipality_North_York',                                          'municipality_Scarborough', 'municipality_Toronto']] 
dummy_municipality.head() # east york dropped, york dropped (as per reco in attempt 10)


# In[8]:

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


# In[9]:

# create dataframes with an intercept column and all other independent variables

y, X = dmatrices('ticketed ~ parking_ticket_ordinal + municipality_Etobicoke + municipality_North_York                   + municipality_Scarborough + municipality_Toronto'                 , model_features, return_type= 'dataframe')


# In[11]:

# flatten y into a 1-D array so that scikit-learn will properly understand it as the response variable.
y = np.ravel(y)


# In[12]:

# initiate logistic regression model, and fit with X (independent variables print X.columns)and y (ticketed = t/f)
model = LogisticRegression()

# train the model
model = model.fit(X, y)

# check the accuracy on the training set
model.score(X, y)


# an 71% accuracy was observed utilizing all variables within model

# In[13]:

y.mean()


# Only 38% of the addresses were ticketed. This means that you could obtain 62% accuracy by always predicting "no".

# In[14]:

# examine the coefficients
pd.DataFrame(zip(X.columns, np.transpose(model.coef_)))


# After the removal of weekend_t, dow_6, dow_1, dow_5, dow_3, dow_4, dow_2. we observe a slight increase from 7.85 to 7.92 in the parking_ticket_ordinal variable and slight decreases with the municipality dummy variables.

# In[15]:

# evaluate the model by splitting into train and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)
model2 = LogisticRegression()
model2.fit(X_train, y_train)


# In[16]:

# predict class labels for the test set
predicted = model2.predict(X_test)
print predicted


# In[17]:

# generate class probabilities
probs = model2.predict_proba(X_test)
print probs


# the classifier is predicting a 1 (parking ticket issued) any time the probability in the second column is greater than 0.5.

# In[18]:

# generate evaluation metrics
print metrics.accuracy_score(y_test, predicted)
print metrics.roc_auc_score(y_test, probs[:, 1])


# Very similar results to attempt 10.

# In[19]:

print metrics.confusion_matrix(y_test, predicted)
print metrics.classification_report(y_test, predicted)


# While the results are very similar to the previous attempt, a decrease in the error rate from 0.76 to 0.55. 

# In[20]:

# evaluate the model using 10-fold cross-validation
scores = cross_val_score(LogisticRegression(), X, y, scoring='accuracy', cv=10)
print scores
print scores.mean()


# In[21]:

from sklearn.feature_selection import RFE
from sklearn.linear_model import LogisticRegression


# In[22]:

# separate dependent / independent variables
x = model_features[['parking_ticket_ordinal', 'municipality_Etobicoke', 'municipality_North_York',                    'municipality_Scarborough', 'municipality_Toronto']].as_matrix()

y = np.ravel(model_features[['ticketed']])
columns = ['parking_ticket_ordinal', 'municipality_Etobicoke', 'municipality_North_York',            'municipality_Scarborough', 'municipality_Toronto']


# In[23]:

# create a base classifier used to evaluate a subset of attributes
rfe_model = LogisticRegression()


# In[24]:

#rank all features, i.e continue the elimination until the last one
rfe = RFE(rfe_model, n_features_to_select=1)
rfe.fit(x,y)


# In[25]:

# summarize the selection of the attributes
print(rfe.support_)
print(rfe.ranking_)


# RFE ranking : parking_ticket_ordinal, municipality_Etobicoke, municipality_Scarborough, municipality_North_York, municipality_Toronto

# In[26]:

from sklearn.linear_model import RandomizedLasso


# In[27]:

# intialize randomized lasso
rlasso = RandomizedLasso(alpha=0.025)
rlasso.fit(x, y)

print "Features sorted by their score:"
print sorted(zip(map(lambda x: round(x, 4), rlasso.scores_), 
                 columns), reverse=True)


# In[28]:

from sklearn.ensemble import ExtraTreesClassifier


# In[29]:

tree_model = ExtraTreesClassifier()
tree_model.fit(x, y)
# display the relative importance of each attribute
print(tree_model.feature_importances_)


# ranking : municipality_Toronto : (0.4453), municipality_Scarborough : (0.1949), municipality_North_York : (0.1474), municipality_Etobicoke : (0.1240), parking_ticket_ordinal : (0.0884)
# 
# Similar to the previous model, the extra trees classifier produces results which are different than what was produced in the RFE simulation as it has assigned a larger weigthing to each municipality and less to parking_ticket_ordinal. 
# 
# Overall the models remained consistent with improvements to the error rate. Given the stability of the model, it makes sense to reduce the variables to municipality and parking_ticket_ordinal. 

# In[ ]:

# test model 43 Dewson (geo_id - 793293)
# sunday - 0
# ticket - 1
# parking_ticket_ordinal - 0
# municipality_Etobicoke - 0
# municipality_North_York - 0
# municipality_Scarborough - 0
# municipality_Toronto - 1


# In[38]:

dataset[test_dataset['geo_id'] == 793293]


# In[40]:

model.predict_proba(np.array([1, 0, 0, 0, 0, 1]))


# there is a 65% chance that you will be issued a ticket on dewson st on sunday

# In[43]:

# test model 205 Humber College Blvd (geo_id - 12387605)
# monday - 1
# ticket - 1
# parking_ticket_ordinal - 4
# municipality_Etobicoke - 1
# municipality_North_York - 0
# municipality_Scarborough - 0
# municipality_Toronto - 0

dataset[test_dataset['geo_id'] == 12387605]


# In[46]:

model.predict_proba(np.array([1, 4, 1, 0, 0, 0]))


# there is a near perfect possibility that you will be issued a ticket if you do not obey the parking bylaws at this address.
