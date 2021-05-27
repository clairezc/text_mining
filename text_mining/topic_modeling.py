

import nltk
import pandas as pd
import sklearn
import re
import requests
import json
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer
from nltk.tokenize import sent_tokenize, word_tokenize
import os

from nltk.stem.wordnet import WordNetLemmatizer
from nltk.stem.porter import PorterStemmer
import string
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import cross_val_score
from nltk import word_tokenize
from nltk.stem import WordNetLemmatizer




##Convert the data into a dataframe

data = pd.read_csv('/Users/chenzhou/LaTeX_files/IST736/final_project/train_data_group_3_final.csv', error_bad_lines=False)
print(data.head())

DescriptionList = []
for nextH in data['Description']:
    DescriptionList.append(nextH)

print("The Description list is")
print(DescriptionList)



class LemmaTokenizer(object):
    def __init__(self):
        self.wnl = WordNetLemmatizer()
    def __call__(self, articles):
        return [self.wnl.lemmatize(t) for t in word_tokenize(articles)]

from sklearn.feature_extraction import text
my_stop_words = text.ENGLISH_STOP_WORDS.union(["ha", "le", "u", "wa", "s", "t", "b", "say", "year", "bbc", "news", "big", "said", "latest", "want", "uk", "old", "set", "time", "world", "new", "quot", "covid"])

## Instantiate Vectorizer
MyVect_lemma = CountVectorizer(input = 'content',
                          analyzer = 'word',
                          tokenizer = LemmaTokenizer(),
                          lowercase = True,
                          stop_words = my_stop_words)

DTM1 = MyVect_lemma.fit_transform(DescriptionList)
vocab = MyVect_lemma.get_feature_names()

DTM2 = DTM1.toarray()
ColumnNames = MyVect_lemma.get_feature_names()
DF = pd.DataFrame(DTM2, columns = ColumnNames)




##Topic Modelling

from sklearn.decomposition import LatentDirichletAllocation

num_topics = 3

lda_model= LatentDirichletAllocation(n_components=num_topics,
                                         learning_decay=0.7,
                                         max_iter=100, learning_method='online')

LDA_Model = lda_model.fit_transform(DF)
print("size: ", LDA_Model.shape)

#print("First headline...")
#print(LDA_Model[0])

def print_topics(model, vectorizer, top_n = 10):
    for idx, topic in enumerate(model.components_):
        print("Topic: ", idx)

        print([(vectorizer.get_feature_names()[i], topic[i])
               for i in topic.argsort()[:-top_n - 1:-1]])

print_topics(lda_model, MyVect_lemma)
print(LDA_Model)
print(lda_model.components_.shape)


##Plot the top words in each topic

import matplotlib.pyplot as plt

word_topic = np.array(lda_model.components_)
word_topic = word_topic.transpose()

num_top_words = 20 ##
vocab_array = np.asarray(vocab)

#fontsize_base = 70 / np.max(word_topic) # font size for word with largest share in corpus
fontsize_base = 8

for t in range(num_topics):
    plt.subplot(1, num_topics, t + 1)  # plot numbering starts with 1
    plt.ylim(0, num_top_words + 0.5)  # stretch the y-axis to accommodate the words
    plt.xticks([])  # remove x-axis markings ('ticks')
    plt.yticks([]) # remove y-axis markings ('ticks')
    plt.title('Topic #{}'.format(t))
    top_words_idx = np.argsort(word_topic[:,t])[::-1]  # descending order
    top_words_idx = top_words_idx[:num_top_words]
    top_words = vocab_array[top_words_idx]
    top_words_shares = word_topic[top_words_idx, t]
    for i, (word, share) in enumerate(zip(top_words, top_words_shares)):
        plt.text(0.3, num_top_words-i-0.5, word, fontsize=fontsize_base)
                 ##fontsize_base*share)

plt.tight_layout()
plt.show()

from sklearn.model_selection import GridSearchCV

## Options to try with the model

#search_params = {
  #'n_components': [3, 4, 5, 6]
#}


## Try all of the options
#gridsearch = GridSearchCV(lda_model, param_grid=search_params, verbose=1)
#gridsearch.fit(DTM1)

## Results
#print("Best Model's Params: ", gridsearch.best_params_)
#print("Best Log Likelihood Score: ", gridsearch.best_score_)


##More plot

import pyLDAvis
import pyLDAvis.sklearn as LDAvis
import IPython


#pyLDAvis.enable_notebook()

panel = LDAvis.prepare(lda_model, DTM1, MyVect_lemma, mds='tsne')
pyLDAvis.show(panel)









