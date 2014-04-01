import csv

ifile  = open('ifbl4.csv', "rb")
reader = csv.reader(ifile, delimiter=';', doublequote=False)
ofile  = open('ifbl4-fixed.csv', "wb")
writer = csv.writer(ofile, delimiter=';')

for row in reader:
    row[0] = row[0].lower()
    row[0] = row[0][:2] + '-' + row[0][2:]
    writer.writerow(row)

ifile.close()
ofile.close()
