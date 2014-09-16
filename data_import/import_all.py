#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import re

sys.path.append('/Users/nicolasnoe/Dropbox/BBPF/python-dwca-reader')

from prompter import yesno

from dwca.read import DwCAReader
from dwca.darwincore.utils import qualname as qn

from db_helpers import (check_db_existence, drop_database, create_database, load_sqlfile,
                        copy_csvfile_to_table, load_sqltemplate, insert_many)

from utils import make_action_or_exit, switch

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

START_AT = 'datacleaning'


def db_creation_step(output_stream):
    if check_db_existence(DB_CONF):
        output_stream.write("Target database already exists.")
        if yesno("Drop it ?", default='no'):
            output_stream.write("Exit\n")
            sys.exit()
        else:
            make_action_or_exit("Dropping existing database...", output_stream, drop_database, DB_CONF)

    make_action_or_exit("Creating database...", output_stream, create_database, DB_CONF)


def load_ifbl_step(output_stream):
    for source in DATA_SOURCES:
        output_stream.write("Importing {fn}...".format(fn=source['fn']))
        f = open(os.path.join(os.path.dirname(__file__), source['fn']), 'rb')
        copy_csvfile_to_table(f, source['table'], source['delimiter'], output_stream, DB_CONF)
        output_stream.write("\n")


def load_florabank_step(output_stream):
    output_stream.write("Importing Florabank data...")
    
    fields = ['scientificName',
              'verbatimCoordinates',
              'verbatimLocality',
              'coordinateUncertaintyInMeters',
              'verbatimCoordinateSystem',
              'associatedReferences',
              'eventDate',
              'recordedBy',
              'catalogNumber',
              ]

    fields_w_long = [(f, qn(f)) for f in fields]

    with DwCAReader(FLORABANK_DWCA) as dwca:
        all_values = []

        for core_row in dwca:
            ar = core_row.data[qn('associatedReferences')]
            # Ignore if not a "streeplijst"
            if re.search('Streeplijst', ar, re.IGNORECASE):
                row_values = []
                for f in fields_w_long:
                    row_values.append(core_row.data[f[1]])

                all_values.append(row_values)

        output_stream.write("Finished loop")
        insert_many('inbo_dwca', [f[0] for f in fields_w_long], all_values, DB_CONF)


def datacleaning_step(output_stream):
    fn = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'fix_dates.tsql')
    load_sqltemplate(fn, {'source_table_2009': 'ifbl_2009'}, DB_CONF)


def main(args):
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)  # No need to flush
    o = sys.stdout

    # Swith-like construct allows to jump directly in the middle of the process if needed
    # (gaining time in development)
    for case in switch(START_AT):
        # 1. Database creation
        if case('db_creation'):
            db_creation_step(o)
        if case('input_schema_creation', 'db_creation'):
            # 2. DB Schema for flat input
            make_action_or_exit("Creating input schema...", o, load_sqlfile, '00_input_schema.sql',
                                DB_CONF)
        if case('ifbl_load', 'input_schema_creation', 'db_creation'):
            # 3. Copy IFBL source data from CSV
            load_ifbl_step(o)
        if case('florabank_load', 'ifbl_load', 'input_schema_creation', 'db_creation'):
            # 4. Import Florabank from DwC-A
            load_florabank_step(o)
        if case('datacleaning', 'florabank_load', 'ifbl_load', 'input_schema_creation', 'db_creation'):
            datacleaning_step(o)
    

if __name__ == "__main__":
    sys.exit(main(sys.argv))
    