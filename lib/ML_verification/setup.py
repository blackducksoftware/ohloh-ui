"""Contains config info. for other python files."""

import os

# Finding rails app directory!!
os.system("rails runner 'puts Rails.root.to_s' > rails_dir.txt")
rails_dir = open('rails_dir.txt', 'r').readline().split()[0]
ML_dir = rails_dir + '/lib/ML_verification'

# Remove the temp file afterwards
os.remove('rails_dir.txt')

# Info of file locations
bag_of_words = ML_dir + '/bag_of_words'
common_domains = ML_dir + '/domains_union.txt'
common_joins = ML_dir + '/joins_union.txt'
common_tails = ML_dir + '/tails_union.txt'
common_url_words = ML_dir + '/url_words'

# Info to access the database
dbname = os.environ['DB_NAME']
host = os.environ['DB_HOST']
password = os.environ['DB_PASSWORD']
port = os.environ['DB_PORT']
user = os.environ['DB_USERNAME']

# File directory for classifiers
classifier_WI = ML_dir + '/avg_PA_result_WI.npy'
classifier_W0 = ML_dir + '/perceptron_result_WO.npy'

# Destination file
destination = ML_dir + '/spammers.txt'
