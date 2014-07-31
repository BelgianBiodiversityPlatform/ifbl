#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os

from prompter import yesno

from dwca.read import DwCAReader
from dwca.darwincore.utils import qualname as qn

from db_helpers import (check_db_existence, drop_database, create_database, load_sqlfile,
                        copy_csvfile_to_table, insert_dict_row)

from utils import make_action_or_exit

SKIP_TO_FLORABANK = True

# Credentials should allow creation/deletion of databases
DB_CONF = {'name': 'ifbl',
           'host': 'localhost',
           'encoding': 'UTF8',
           'username': 'nicolasnoe'}

# Source files to import
DATA_SOURCES = [{'fn': './ifbl_csv_source/IFBL2009.csv', 'delimiter': ',', 'table': 'ifbl_2009'},
                {'fn': './ifbl_csv_source/IFBL2010.csv', 'delimiter': ',', 'table': 'ifbl_2010'},
                {'fn': './ifbl_csv_source/IFBL2013.csv', 'delimiter': ';', 'table': 'ifbl_2013'}]

FLORABANK_DWCA = '/Users/nicolasnoe/Downloads/dwca-florabank1-occurrences.zip'


def main(prog_args):
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)  # No need to flush
    o = sys.stdout

    if not SKIP_TO_FLORABANK:
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

        # 3. Copy IFBL source data from CSV
        for source in DATA_SOURCES:
            o.write("Importing {fn}...".format(fn=source['fn']))
            f = open(os.path.join(os.path.dirname(__file__), source['fn']), 'rb')
            copy_csvfile_to_table(f, source['table'], source['delimiter'], o, DB_CONF)
            o.write("\n")

    # 4. Import Florabank from DwC-A
    o.write("Importing Florabank data...")
    with DwCAReader(FLORABANK_DWCA) as dwca:
        for core_row in dwca:
            d = {'scientificName': core_row.data[qn('scientificName')],
                 'verbatimCoordinates': core_row.data[qn('verbatimCoordinates')],
                 'verbatimLocality': core_row.data[qn('verbatimLocality')],
                 'coordinateUncertaintyInMeters': core_row.data[qn('coordinateUncertaintyInMeters')],
                 'verbatimCoordinateSystem': core_row.data[qn('verbatimCoordinateSystem')],
                 'associatedReferences': core_row.data[qn('associatedReferences')],
                 'eventDate': core_row.data[qn('eventDate')],
                 'recordedBy': core_row.data[qn('recordedBy')],
                 'catalogNumber': core_row.data[qn('catalogNumber')]
                 }

            insert_dict_row('inbo_dwca', d, DB_CONF)

if __name__ == "__main__":
    sys.exit(main(sys.argv))
    