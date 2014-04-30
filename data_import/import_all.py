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


def main(prog_args):
    o = sys.stdout

    if check_db_existence(DB_CONF):
        o.write("Target database already exists.")
        if yesno("Drop it ?", default='no'):
            o.write("Exit\n")
            sys.exit()
        else:
            make_action_or_exit("Dropping existing database...", o, drop_database, DB_CONF)

    make_action_or_exit("Creating database...", o, create_database, DB_CONF)
    make_action_or_exit("Creating input schema...", o, load_sqlfile, '00_input_schema.sql', DB_CONF)

    fn = os.path.join(os.path.dirname(__file__), './ifbl_csv_source/IFBL2009.csv')
    copy_csvfile_to_table(open(fn), 'ifbl_2009', DB_CONF)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
