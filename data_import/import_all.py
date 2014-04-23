#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys

from prompter import yesno

from db_helpers import check_db_existence, drop_database, create_database
from utils import make_action_or_exit

# Credentials should allow creation/deletion of databases
DB = {'name': 'ifbl',
      'host': 'localhost',
      'encoding': 'UTF8',
      'username': 'nicolasnoe'}


def main(prog_args):
    o = sys.stdout

    if check_db_existence(DB):
        o.write("Target database already exists.")
        if yesno("Drop it ?", default='no'):
            o.write("Exit\n")
            sys.exit()
        else:
            make_action_or_exit("Dropping existing database...", o, drop_database, DB)

    make_action_or_exit("Creating database...", o, create_database, DB)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
