#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os

from prompter import yesno

from db_helpers import check_db_existence, drop_database, create_database, load_sqlfile, copy_csvfile_to_table
from utils import make_action_or_exit

# Credentials should allow creation/deletion of databases
DB_CONF = {'name': 'ifbl',
           'host': 'localhost',
           'encoding': 'UTF8',
           'username': 'nicolasnoe'}

# Source files to import
DATA_SOURCES = [{'fn': './ifbl_csv_source/IFBL2009.csv', 'delimiter': ',', 'table': 'ifbl_2009'},
                {'fn': './ifbl_csv_source/IFBL2010.csv', 'delimiter': ',', 'table': 'ifbl_2010'},
                {'fn': './ifbl_csv_source/IFBL2013.csv', 'delimiter': ';', 'table': 'ifbl_2013'}]
                    

def main(prog_args):
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)  # No need to flush
    o = sys.stdout

    # 1. Database creation
    if check_db_existence(DB_CONF):
        o.write("Target database already exists.")
        if yesno("Drop it ?", default='no'):
            o.write("Exit\n")
            sys.exit()
        else:
            make_action_or_exit("Dropping existing database...", o, drop_database, DB_CONF)

    make_action_or_exit("Creating database...", o, create_database, DB_CONF)
    
    # 2. DB Schema for flat input
    make_action_or_exit("Creating input schema...", o, load_sqlfile, '00_input_schema.sql', DB_CONF)

    # 3. Copy source data from CSV

    # CSV Source files copy
    for source in DATA_SOURCES:
        o.write("Importing {fn}...".format(fn=source['fn']))
        f = open(os.path.join(os.path.dirname(__file__), source['fn']), 'rb')
        copy_csvfile_to_table(f, source['table'], source['delimiter'], o, DB_CONF)
        o.write("\n")


if __name__ == "__main__":
    sys.exit(main(sys.argv))
    