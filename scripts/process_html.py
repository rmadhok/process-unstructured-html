""" Converting Unstructured HTML data files to consolidated CSV

 Summary:  There are HTML files with data on health indicators
 for each district in all states of India from 2009-2015. The
 algorithm iteratively accepts data from each 
 state-year, returns a list of dictionaries with key-value
 pairs for each row-column element, and converts this into 
 a data frame.

 Data source: https://nrhm-mis.nic.in/hmisreports/frmstandard_reports.aspx
"""
__author__ = "Raahil Madhok"
__copyright__ = "Copyright 2016"
__version__ = "1.0"
__maintainer__ = "Raahil Madhok"
__email__ = "raahil_madhok@hks.harvard.edu"
__status__ = "Production"

# Import libraries
import os
import pandas as pd
from functions import Soupify, html_to_list

# TOP PATH
# Read
dir_read = '/Users/rmadhok/Dropbox (CID)/HMIS/data/raw/'
# Write
dir_write = '/Users/rmadhok/Dropbox (CID)/HMIS/data/clean/'

## Apply html->csv function on all state-year files
# Init list to hold dictionary data from each state-year
master_data = []
for root, dirs, files in os.walk(dir_read):
	for name in files:
		if not name.startswith('.'):
			path = os.path.join(root, name)
			print "Pulling file from " + path + "..."

			# Pass html file to html_to_list and
			# append state-year data to list
			master_data += html_to_list(path)
			print "Adding state data to master..."

# Convert final data to datafram and csv
data_full = pd.DataFrame(master_data)
os.chdir(dir_write)
data_full.to_csv('hmis_unshaped.csv', encoding = 'utf-8')
