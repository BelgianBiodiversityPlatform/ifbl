#! /usr/bin/env python
# -*- coding: utf-8 -*-

# TODO: Make sure every failed step return False so next step are not executed
# TODO: Make sure each step is repeatable without error (TRUNCATE before INSERT, ...)

import sys
import os
import re
import datetime

sys.path.append('/Users/nicolasnoe/Dropbox/BBPF/python-dwca-reader')

from prompter import yesno

from dwca.read import DwCAReader
from dwca.darwincore.utils import qualname as qn

from db_helpers import (check_db_existence, drop_database, create_database,
                        copy_csvfile_to_table, load_sqltemplate, insert_many)

from utils import make_action_or_exit, switch, acolors

START_AT_STEP = 'create_tapir_view'

# Credentials should allow creation/deletion of databases
DB_CONF = {'name': 'ifbl',
           'host': 'localhost',
           'encoding': 'UTF8',
           'username': 'nicolasnoe'}

WORK_SCHEMA_NAME = 'nbgb_ifbl'

# Source files to import
DATA_SOURCES = [{'id': 1,
                 'type': 'ifbl',
                 'label': 'IFBL digit2009',
                 'fn': './ifbl_csv_source/IFBL2009.csv',
                 'delimiter': ',',
                 'table': 'ifbl_2009',
                 'cleaning_file': 'input_cleaning_ifbl2009.tsql'},

                {'id': 2,
                 'type': 'ifbl',
                 'label': 'IFBL digit2010',
                 'fn': './ifbl_csv_source/IFBL2010.csv',
                 'delimiter': ',',
                 'table': 'ifbl_2010',
                 'cleaning_file': 'input_cleaning_ifbl2010.tsql'},

                {'id': 3,
                 'type': 'ifbl',
                 'label': 'IFBL digit2013',
                 'fn': './ifbl_csv_source/IFBL2013.csv',
                 'delimiter': ';',
                 'table': 'ifbl_2013',
                 'cleaning_file': 'input_cleaning_ifbl2013.tsql'},

                {'id': 4,
                 'type': 'florabank',
                 'label': 'Florabank',
                 'fn': '/Users/nicolasnoe/Downloads/dwca-florabank1-occurrences.zip',
                 'table': 'inbo_dwca'}
                ]

IFBL_DATA_SOURCES = [s for s in DATA_SOURCES if s['type'] == 'ifbl']
FLORABANK_DATA_SOURCES = [s for s in DATA_SOURCES if s['type'] == 'florabank']


def sqltemplate_absolute_path(filename):
    return os.path.join(os.path.dirname(os.path.realpath(__file__)), 'sqltemplates', filename)


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
        if source['type'] == 'ifbl':
            output_stream.write(acolors.BOLD + "Importing {fn}...".format(fn=source['fn']) + acolors.ENDC)
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

    for source in DATA_SOURCES:
        if source['type'] == 'florabank':
            with DwCAReader(source['fn']) as dwca:
                all_values = []

                for core_row in dwca:
                    ar = core_row.data[qn('associatedReferences')]
                    # Ignore if not a "streeplijst"
                    if re.search('Streeplijst', ar, re.IGNORECASE):
                        row_values = []
                        for f in fields_w_long:
                            row_values.append(core_row.data[f[1]])

                        all_values.append(row_values)

                output_stream.write("Finished reading...")
                insert_many(source['table'], [f[0] for f in fields_w_long], all_values, DB_CONF)
                output_stream.write("Finished inserting...")


def datacleaning_step(output_stream):
    for source in DATA_SOURCES:
        if source['type'] == 'ifbl':
            output_stream.write(acolors.BOLD + "Cleaning {fn}...".format(fn=source['label']) + acolors.ENDC)
            load_sqltemplate(sqltemplate_absolute_path(source['cleaning_file']), {'table': source['table']}, False, DB_CONF)


def create_work_schema_step(output_stream):
    context = {'work_schema': WORK_SCHEMA_NAME}

    return load_sqltemplate(sqltemplate_absolute_path('work_schema.tsql'), context, False, DB_CONF)


def copy_input_to_work_step(output_stream):
    context = {'work_schema': WORK_SCHEMA_NAME,
               'ifbl_data_sources': IFBL_DATA_SOURCES,
               'all_data_sources': DATA_SOURCES,
               'florabank_data_sources': FLORABANK_DATA_SOURCES}

    return load_sqltemplate(sqltemplate_absolute_path('data_copy.tsql'), context, True, DB_CONF)


def create_view_step(output_stream):
    # Only IFBL data is published, Florabank is already published by INBO !!
    context = {'work_schema': WORK_SCHEMA_NAME,
               'current_date': datetime.date.today().strftime("%Y-%m-%d"),
               'comma_separated_ifbl_ids': ','.join(map(str, [s['id'] for s in IFBL_DATA_SOURCES]))
               }
    return load_sqltemplate(sqltemplate_absolute_path('create_view.tsql'), context, True, DB_CONF)


def main(args):
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)  # No need to flush
    o = sys.stdout

    # Swith-like construct allows to jump directly in the middle of the process if needed
    # (gaining time in development)
    previous_steps = []
    for case in switch(START_AT_STEP):
        # 1. Database creation
        if case('db_creation', *previous_steps):
            previous_steps.append('db_creation')  # Ensure we'll also perform next actions
            db_creation_step(o)
        if case('input_schema_creation', *previous_steps):
            previous_steps.append('input_schema_creation')
            # 2. DB Schema for flat input
            context = {'ifbl_data_sources': IFBL_DATA_SOURCES,
                       'florabank_data_sources': FLORABANK_DATA_SOURCES}

            make_action_or_exit("Creating input schema...", o, load_sqltemplate,
                                sqltemplate_absolute_path('input_schema.tsql'),
                                context, False, DB_CONF)
        if case('ifbl_load', *previous_steps):
            previous_steps.append('ifbl_load')
            # 3. Copy IFBL source data from CSV
            load_ifbl_step(o)
        if case('florabank_load', *previous_steps):
            previous_steps.append('florabank_load')
            # 4. Import Florabank from DwC-A
            load_florabank_step(o)
        if case('data_cleaning', *previous_steps):
            previous_steps.append('data_cleaning')
            datacleaning_step(o)
        if case('work_schema', *previous_steps):
            previous_steps.append('work_schema')
            make_action_or_exit("Creating working schema...", o, create_work_schema_step, o)
        if case('copy_input_to_work', *previous_steps):
            previous_steps.append('copy_input_to_work')
            make_action_or_exit("Copy data from input schema to work schema...", o, copy_input_to_work_step, o)
        if case('create_tapir_view', *previous_steps):
            previous_steps.append('create_tapir_view')
            make_action_or_exit("Create TAPIR view for GBIF...", o, create_view_step, o)

    

if __name__ == "__main__":
    sys.exit(main(sys.argv))
    