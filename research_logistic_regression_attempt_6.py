
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
dataset = pd.read_sql_query("SELECT ticketed, municipality, ward_id, geo_id, month, season, dayofweek, weekend,                              parking_tickets                              FROM address_monthly_dow_rank;", engine)

dataset.head()


# In[14]:

# separate parking tickets into 5 quantiles
dataset_quantile_1 = dataset['parking_tickets'].quantile(0.20)
dataset_quantile_2 = dataset['parking_tickets'].quantile(0.40)
dataset_quantile_3 = dataset['parking_tickets'].quantile(0.60)
dataset_quantile_4 = dataset['parking_tickets'].quantile(0.80)
dataset_quantile_5 = dataset['parking_tickets'].quantile(1)

print(dataset['parking_tickets'].quantile(0.89))
print(dataset_quantile_1)
print(dataset_quantile_2)
print(dataset_quantile_3)
print(dataset_quantile_4)
print(dataset_quantile_5)


# An attempt to place the parking tickets into quantiles proved difficult as parking tickets within the dataset only began to increase past 0 at the 89 percentile 
