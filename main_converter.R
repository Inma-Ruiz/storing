
# To convert your MS word report into an HTML report via an intermediate report.qmd:

# 1 - Run this script
# 2 - Open the report.qmd inside the output folder
# 3 - Click render button
# 4 - Find the report.html inside the output folder

# 5 - Tune it: You may need to go back to report.qmd for small tweaks

source("make_qmd3.R")
make_qmd3("input/report.docx")