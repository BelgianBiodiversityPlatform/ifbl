#! /usr/bin/env python
# -*- coding: utf-8 -*-

# TODO: Make sure every failed step return False so next step are not executed
# TODO: Make sure each step is repeatable without error (TRUNCATE before INSERT, ...)

import sys
import os
import re
import datetime

import urllib2

sys.path.append('/Users/nicolasnoe/Dropbox/BBPF/python-dwca-reader')

import psycopg2
import psycopg2.extras

from prompter import yesno
from furl import furl

from dwca.read import DwCAReader
from dwca.darwincore.utils import qualname as qn

from db_helpers import (check_db_existence, drop_database, create_database,
                        copy_csvfile_to_table, load_sqltemplate, insert_many, DBConnection)

from utils import make_action_or_exit, switch, acolors, char_range

START_AT_STEP = 'db_creation'

# Credentials should allow creation/deletion of databases
DB_CONF = {'name': 'ifbl',
           'host': 'localhost',
           'encoding': 'UTF8',
           'username': 'nicolasnoe'}

WORK_SCHEMA_NAME = 'nbgb_ifbl'
POSTGIS_SCHEMA_NAME = 'gis'

# We rely on GEOWEBAPI to get details about IFBL squares
GEOWEBAPI_URL = "http://dev:4567/ifbl_square"

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
               'florabank_data_sources': FLORABANK_DATA_SOURCES,
               'large_areas_codes': _get_large_areas_codes()}

    return load_sqltemplate(sqltemplate_absolute_path('data_copy.tsql'), context, False, DB_CONF)


def create_views_step(output_stream):
    # Only IFBL data is published, Florabank is already published by INBO !!
    context = {'work_schema': WORK_SCHEMA_NAME,
               'current_date': datetime.date.today().strftime("%Y-%m-%d"),
               'comma_separated_ifbl_ids': ','.join(map(str, [s['id'] for s in IFBL_DATA_SOURCES]))
               }
    return load_sqltemplate(sqltemplate_absolute_path('create_views.tsql'), context, False, DB_CONF)


# Query GeoWebApi and return (polygon, t)
# polygon: WKT string or False if unkown
# t: IFBL 4km, IFBL 1km, ...
def _get_square_details(ifbl_square_code):
    stripped_code = ifbl_square_code.replace('-', '')

    if len(stripped_code) == 4:
        t = "IFBL 4km"
    elif len(stripped_code) == 6:
        t = "IFBL 1km"

    req = furl(GEOWEBAPI_URL)
    req.args['id'] = stripped_code
    req.args['epsg'] = 3857
    # Get the polygon
    req.args['type'] = 'polygon'
    
    r = urllib2.urlopen(req.url).read()
    if r == "FALSE":
        polygon = False
    else:
        polygon = r

    return (polygon, t)


def load_squares_step(output_stream):
    with DBConnection(DB_CONF) as conn:
        read_cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        read_cur.execute("""SELECT * from {schema}.areas""".format(schema=WORK_SCHEMA_NAME))
        write_cur = conn.cursor()

        # First, add a column for the geometry
       
        q = "ALTER TABLE {work_schema}.areas DROP COLUMN IF EXISTS the_geom CASCADE;".format(work_schema=WORK_SCHEMA_NAME)
        write_cur.execute(q)
        conn.commit()

        q = "ALTER TABLE {work_schema}.areas ADD COLUMN the_geom {postgis_schema}.geometry(Polygon, 3857);".format(work_schema=WORK_SCHEMA_NAME, postgis_schema=POSTGIS_SCHEMA_NAME)
        write_cur.execute(q)
        conn.commit()

        for record in read_cur:
            wkt, t = _get_square_details(record['ifbl_code'])
            if wkt:
                params = {'wkt': wkt, 'id': record['id']}
                q = "UPDATE {schema}.areas SET the_geom = {postgis_schema}.ST_GeomFromText(%(wkt)s, 3857) WHERE id = %(id)s".format(schema=WORK_SCHEMA_NAME, postgis_schema=POSTGIS_SCHEMA_NAME)
                write_cur.execute(q, params)

            q = "UPDATE {schema}.areas SET coordinatesystem = %(t)s WHERE id = %(id)s".format(schema=WORK_SCHEMA_NAME)
            write_cur.execute(q, {'t': t, 'id': record['id']})
        
        conn.commit()

    return True


def install_postgis_step(output_stream):
    context = {'postgis_schema': POSTGIS_SCHEMA_NAME}
    return load_sqltemplate(sqltemplate_absolute_path('install_postgis.tsql'), context, False, DB_CONF)


def _format_ifbl_code(a, b, c):
    return "{a}{b}-{c}".format(a=a, b=b, c=c)


def _get_large_areas_codes():
    # In additions to the used areas/squares that will be extracted directly from IFBL/Florabank
    # data, we also want(for the website) all the 4x4 squares, even if there will be no data there
    
    codes = []
    for c in char_range('a', 'm'):
        for d in range(0, 10):
            for e in range(11, 19):
                code = _format_ifbl_code(c, d, e)
                codes.append(code)
            for e in range(21, 29):
                code = _format_ifbl_code(c, d, e)
                codes.append(code)
            for e in range(31, 39):
                code = _format_ifbl_code(c, d, e)
                codes.append(code)
            for e in range(41, 49):
                code = _format_ifbl_code(c, d, e)
                codes.append(code)
            for e in range(51, 59):
                code = _format_ifbl_code(c, d, e)
                codes.append(code)

    return codes


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
        if case('install_postgis', *previous_steps):
            previous_steps.append('install_postgis')
            make_action_or_exit("Install PostGIS into database...", o, install_postgis_step, o)
        if case('load_square_details', *previous_steps):
            previous_steps.append('load_square_details')
            make_action_or_exit("Load IFBL square details from webservice...", o, load_squares_step, o)
        if case('create_views', *previous_steps):
            previous_steps.append('create_views')
            make_action_or_exit("Create various views...", o, create_views_step, o)

if __name__ == "__main__":
    sys.exit(main(sys.argv))
    