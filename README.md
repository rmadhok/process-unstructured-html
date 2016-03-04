# Structuring an Endless Sea of Unstructured HTML Files

## Summary 
March 4, 2016. It is hard to come across high-quality data on health indicators in India. Recently, each district (n=640) has been collecting health data each month from their hospital and reporting to the state. The state then uploads the data through and internal management information system (MIS), which the central government makes available to the public. It seems that the MIS stores uploaded data as HTML, and the government informatics centre decided to be mean and not covert the data before making it public. This set of scripts iterates through each state-year HTML file (30 states x 6 years = 180 files), parses the data, and structures it into a clean, state-of-the-art panel dataset which can be easily merged with other Indian demographic data to study health trends in the country.

## Data Structure
Data can be found in the standard reports section [here](https://nrhm-mis.nic.in/SitePages/Home.aspx)

1. Districts collect ~200 health indicators from hospitals.
2. State-year HTML files have months as columns and questions as rows, for each district. So, if a state has 50 districts, the html file has 50 x 200 = 10,000 row elements (it would have 60,000 rows in the full panel). 
3. The python script outputs data in long-form, with almost 2 million rows
4. The final, cleaned panel contains reshaped data identified at the state-district-year-month level.

## File List
1. process_html.py is a python script that loops through all file directories, parses HTML, and returns a long-form strcutured csv
2. functions.py contains the functions used in process_html.py
3. hmis_construct_2.do reads the output from process_html.py and reshapes + cleans the data into a useable panel. I find it easier to reshape data in Stata instead of python.
4. data_convert.sh is a basic shell script that calls the python and stata script one after another

## To-do
1. ~~Git~~
2. ~~download data zip files from hmis website~~
3. ~~Write test script for one html file~~
4. ~~put everything in a lopp~~
5. ~~write funtions to do the work~~
6. ~~figure out how to reshape the data~~
7. Cron job to audomatically update data each month?


