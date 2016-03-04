# Shell Script to run python Script
# for parsing html to csv, and then
# Run stata to clean and construct
# panel data

cd "Dropbox (CID)/HMIS/scripts"
python process_html.py
stata -b do 