'''
  This program shell reads phrase data for the kaggle phrase sentiment classification problem.
  The input to the program is the path to the kaggle directory "corpus" and a limit number.
  The program reads all of the kaggle phrases, and then picks a random selection of the limit number.
  It creates a "phrasedocs" variable with a list of phrases consisting of a pair
    with the list of tokenized words from the phrase and the label number from 1 to 4
  It prints a few example phrases.

  I created 4 feature sets, and trained and tested the classifier. The unigram feature set was used 
  as the baseline, and then 500 bigram-features were added, then POS-features. I also tried adding 
  features based on a subjectivity lexicon. More work can be done (e.g., removing stop words, 
  adding features based on pos/neg affixes). 
  

  Usage:  python classifyKaggle.py  <corpus directory path> <limit number>
'''
# open python and nltk packages needed for processing
import os
import sys
import random
import nltk
from nltk.corpus import stopwords
from nltk.collocations import *

#import sentiment_read_subjectivity
# initialize the positive, neutral and negative word lists
#(positivelist, neutrallist, negativelist) 
#    = sentiment_read_subjectivity.read_three_types('SentimentLexicons/subjclueslen1-HLTEMNLP05.tff')
SLpath = '/Users/chenzhou/LaTeX_files/NLP/kagglemoviereviews/SentimentLexicons/subjclueslen1-HLTEMNLP05.tff'

def readSubjectivity(path):
  flexicon = open(path, 'r')
  # initialize an empty dictionary
  sldict = {}
  for line in flexicon:
    fields = line.split()  # default is to split on whitespace
    # split each field on the '=' and keep the second part as the value
    strength = fields[0].split("=")[1]
    word = fields[2].split("=")[1]
    posTag = fields[3].split("=")[1]
    stemmed = fields[4].split("=")[1]
    polarity = fields[5].split("=")[1]
    if (stemmed == 'y'):
      isStemmed = True
    else:
      isStemmed = False
    # put a dictionary entry with the word as the keyword
    #     and a list of the other values
    sldict[word] = [strength, posTag, isStemmed, polarity]
  return sldict

SL = readSubjectivity(SLpath)







#import sentiment_read_LIWC_pos_neg_words
# initialize positve and negative word prefix lists from LIWC 
#   note there is another function isPresent to test if a word's prefix is in the list
#(poslist, neglist) = sentiment_read_LIWC_pos_neg_words.read_words()

# define a feature definition function here

# use NLTK to compute evaluation measures from a reflist of gold labels
#    and a testlist of predicted labels for all labels in a list
# returns lists of precision and recall for each label


# function to read kaggle training file, train and test a classifier 
def processkaggle(dirPath,limitStr):
  # convert the limit argument from a string to an int
  limit = int(limitStr)
  
  os.chdir(dirPath)
  
  f = open('./train.tsv', 'r')
  # loop over lines in the file and use the first limit of them
  phrasedata = []
  for line in f:
    # ignore the first line starting with Phrase and read all lines
    if (not line.startswith('Phrase')):
      # remove final end of line character
      line = line.strip()
      # each line has 4 items separated by tabs
      # ignore the phrase and sentence ids, and keep the phrase and sentiment
      phrasedata.append(line.split('\t')[2:4])
  
  # pick a random sample of length limit because of phrase overlapping sequences
  random.shuffle(phrasedata)
  phraselist = phrasedata[:limit]

  print('Read', len(phrasedata), 'phrases, using', len(phraselist), 'random phrases')

  for phrase in phraselist[:10]:
    print (phrase)
  
  # create list of phrase documents as (list of words, label)
  phrasedocs = []
  # add all the phrases
  for phrase in phraselist:
    tokens = nltk.word_tokenize(phrase[0])
    phrasedocs.append((tokens, int(phrase[1])))
  
  # print a few
  for phrase in phrasedocs[:10]:
    print (phrase)

  # possibly filter tokens


  # continue as usual to get all words and create word features
  stop_words = set(stopwords.words('english'))
  all_words_list = [word for (sent, cat) in phrasedocs for word in sent if not word in stop_words]
  all_words = nltk.FreqDist(all_words_list)
  word_items = all_words.most_common(5000)
  word_features = [word for (word, freq) in word_items]

  # feature sets from a feature definition function

  def document_features(document, word_features):
    document_words = set(document)
    features = {}
    for word in word_features:
      features['contains({})'.format(word)] = word in document_words
    return features


  featuresets = [(document_features(d, word_features), c) for (d, c) in phrasedocs]

  # train classifier and show performance in cross-validation

  train_set, test_set = featuresets[1000:], featuresets[:1000]
  classifier = nltk.NaiveBayesClassifier.train(train_set)
  print(nltk.classify.accuracy(classifier, test_set))

  classifier.show_most_informative_features(30)

  ## bigram feature set
  bigram_measures = nltk.collocations.BigramAssocMeasures()
  finder = BigramCollocationFinder.from_words(all_words_list)

  bigram_features = finder.nbest(bigram_measures.chi_sq, 500)
  print(bigram_features[:50])

  def bigram_document_features(document, word_features, bigram_features):
    document_words = set(document)
    document_bigrams = nltk.bigrams(document)
    features = {}
    for word in word_features:
      features['contain({})'.format(word)] = (word in document_words)
    for bigram in bigram_features:
      features['bigram({} {})'.format(bigram[0], bigram[1])] = (bigram in document_bigrams)
    return features

  bigram_featuresets = [(bigram_document_features(d, word_features, bigram_features), c) for (d, c) in phrasedocs]
  print(len(bigram_featuresets[0][0].keys()))

  train_set, test_set = bigram_featuresets[200:], bigram_featuresets[:200]
  classifier = nltk.NaiveBayesClassifier.train(train_set)
  print(nltk.classify.accuracy(classifier, test_set))

  classifier.show_most_informative_features(30)

  def POS_features(document):
    document_words = set(document)
    tagged_words = nltk.pos_tag(document)
    features = {}
    for word in word_features:
      features['contains({})'.format(word)] = (word in document_words)
    numNoun = 0
    numVerb = 0
    numAdj = 0
    numAdverb = 0
    for (word, tag) in tagged_words:
      if tag.startswith('N'): numNoun += 1
      if tag.startswith('V'): numVerb += 1
      if tag.startswith('J'): numAdj += 1
      if tag.startswith('R'): numAdverb += 1
    features['nouns'] = numNoun
    features['verbs'] = numVerb
    features['adjectives'] = numAdj
    features['adverbs'] = numAdverb
    return features


  POS_featuresets = [(POS_features(d), c) for (d, c) in phrasedocs]
  print(len(POS_featuresets[0][0].keys()))

  train_set, test_set = POS_featuresets[1000:], POS_featuresets[:1000]
  classifier = nltk.NaiveBayesClassifier.train(train_set)
  print(nltk.classify.accuracy(classifier, test_set))

  classifier.show_most_informative_features(30)

  ##subjectivity lexicon

  def SL_features(document, SL):
    document_words = set(document)
    features = {}
    for word in word_features:
      features['contains({})'.format(word)] = (word in document_words)
    # count variables for the 4 classes of subjectivity
    positive = 0
    neutral = 0
    negative = 0

    for word in document_words:
      if word in SL:
        strength, posTag, isStemmed, polarity = SL[word]
        if polarity == 'positive':
          positive += 1
        if polarity == 'neutral':
          neutral += 1
        if polarity == 'negative':
          negative += 1
        features['positivecount'] = positive
        features['neutralcount']  = neutral
        features['negativecount'] = negative
    return features

  SL_featuresets = [(SL_features(d, SL), c) for (d, c) in phrasedocs]

  # show just the two sentiment lexicon features in document 0
  #print(SL_featuresets[0][0]['positivecount'])
  #print(SL_featuresets[0][0]['negativecount'])

  train_set, test_set = SL_featuresets[1000:], SL_featuresets[:1000]
  classifier = nltk.NaiveBayesClassifier.train(train_set)
  print(nltk.classify.accuracy(classifier, test_set))

  classifier.show_most_informative_features(30)

  ##cross validation
  def cross_validation(num_folds, featuresets):
    subset_size = len(featuresets) // num_folds
    accuracy_list = []
    # iterate over the folds
    for i in range(num_folds):
      test_this_round = featuresets[i * subset_size:][:subset_size]
      train_this_round = featuresets[:i * subset_size] + featuresets[(i + 1) * subset_size:]
      # train using train_this_round
      classifier = nltk.NaiveBayesClassifier.train(train_this_round)
      # evaluate against test_this_round and save accuracy
      accuracy_this_round = nltk.classify.accuracy(classifier, test_this_round)
      print(i, accuracy_this_round)
      accuracy_list.append(accuracy_this_round)
    # find mean accuracy over all rounds
    print('mean accuracy', sum(accuracy_list) / num_folds)


  #cross_validation(10, featuresets)
  #cross_validation(10, bigram_featuresets)
  #cross_validation(10, POS_featuresets)



processkaggle('/Users/chenzhou/LaTeX_files/NLP/kagglemoviereviews/corpus/', 5000)

"""
commandline interface takes a directory name with kaggle subdirectory for train.tsv
   and a limit to the number of kaggle phrases to use
It then processes the files and trains a kaggle movie review sentiment classifier.

"""
if __name__ == '__main__':
    if (len(sys.argv) != 3):
        print ('usage: classifyKaggle.py <corpus-dir> <limit>')
        sys.exit(0)
    processkaggle(sys.argv[1], sys.argv[2])