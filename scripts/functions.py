import os
from bs4 import BeautifulSoup


def Soupify(file_path):
	""" 
	Applies BeautifulSoup to html file 
	"""

	with open(file_path, 'r') as f:
		html = f.read()
		soup = BeautifulSoup(html, "html.parser")
	return soup 

# Convert html to csv
def html_to_list(directory):
	""" iteratively structures each row of html data into a dictionary with
		column names and returns a massive list of dictionaries for each row
	"""

	# Extract state and year from file path
	state = os.path.splitext(os.path.basename(directory))[0]
	year = os.path.split(os.path.dirname(directory))[1]

	print "Converting " + str(year) + " " + str(state)  + " data from HTML to csv..."

	# Initialize placeholders for district, question, and question name
	district = None
	question_no = None
	question_name = None

	# Initialize Empty list to hold dictionary of each row/col value
	state_list = []

	# Soup the passed html file
	my_soup = Soupify(directory)

	# Extract list of rows
	rows = my_soup.findAll('tr')

	# For each row, structure data into list
	for row in rows[2:len(rows)]:
		# initialize dictionary to hold row 
		# data as key-value pairs
		my_dict = {}
		cols = row.findAll('td')

		if len(cols) == 17:
			district = cols[0].text
			question_no = cols[1].text
			question_name = cols[2].text
			del cols[0:3]
		elif len(cols) == 16:
			question_no = cols[0].text
			question_name = cols[1].text
			del cols[0:2]
		# Add data to dictionary
		my_dict['state'] = state
		my_dict['year'] = year
		my_dict['district'] = district
		my_dict['q_no'] = question_no
		my_dict['q_name'] = question_name
		my_dict['q_subname'] = cols[0].text
		my_dict['m4'] = cols[1].text
		my_dict['m5'] = cols[2].text
		my_dict['m6'] = cols[3].text
		my_dict['m7'] = cols[4].text
		my_dict['m8'] = cols[5].text
		my_dict['m9'] = cols[6].text
		my_dict['m10'] = cols[7].text
		my_dict['m11'] = cols[8].text
		my_dict['m12'] = cols[9].text
		my_dict['m1'] = cols[10].text
		my_dict['m2'] = cols[11].text
		my_dict['m3'] = cols[12].text

		# Append row dictionary to list
		state_list.append(my_dict)

	# return list of dictionaries
	return state_list