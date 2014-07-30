import psycopg2
import csv

from utils import exec_shell

# TODO: Currently, this only works when Postgres user doesn't need to provide a password...
# (Do this by using only psycopg2 instead of PG binaries - createdb, psql, ...) ?
# We should also support setting a port number !!


def _make_db_args(params):
    """Return connection arguments for CLI tools, excluding database name."""
    return "-h{hostname} -U{username}".format(hostname=params['host'],
                                              username=params['username'])


def _make_db_args_name(params):
    return _make_db_args(params) + " " + params['name']


class DBConnection(object):
    def __init__(self, params):
        self.connection = psycopg2.connect(database=params['name'],
                                           user=params['username'],
                                           host=params['host'])

    def __enter__(self):
        return self.connection

    def __exit__(self, type, value, traceback):
        self.connection.close()


def _connect(params):
    """Connect to the database and return the connexion object."""
    return psycopg2.connect(database=params['name'], user=params['username'], host=params['host'])


def check_db_existence(params):
    """Return True if database exists."""

    cmd = "psql " + _make_db_args(params) + " -lqt | cut -d \| -f 1 | grep -w {db_name}".format(db_name=params['name'])
    return exec_shell(cmd)


def create_database(params):
    cmd = "createdb" + " " + _make_db_args_name(params)
    return exec_shell(cmd)


def drop_database(params):
    cmd = "dropdb" + " " + _make_db_args_name(params)
    return exec_shell(cmd)


def load_sqlfile(filename, db_params):
    cmd = "psql {host_user} -d {db} -f {filename}".format(
        host_user=_make_db_args(db_params),
        db=db_params['name'],
        filename=filename)
    
    return exec_shell(cmd)


def copy_csvfile_to_table(f, table_name, delimiter, output_stream, db_params):
    with DBConnection(db_params) as conn:
        cur = conn.cursor()

        # cur.copy_from is shitty() (quotes, error messages, ...)
        # so we have to reinvent the wheel
        # UGLY UGLY UGLY (but works)
        input_file = csv.DictReader(f, delimiter=delimiter)

        processed_rows_counter = 0
        for row in input_file:
            fields_list, values_list = [], []
            for k, v in row.iteritems():
                fields_list.append('"' + k + '"')
                values_list.append(v)

            s = "INSERT INTO " + table_name + " ({fields})".format(fields=','.join(fields_list)) + " VALUES (" + _get_placeholders_string(fields_list) + ")"
            cur.execute(s, tuple(values_list))
            if cur.rowcount != 1:
                output_stream.write("ERROR: rowcount is {rowcount} for {query}\n".format(rowcount=cur.rowcount, query=s))

            processed_rows_counter += 1

        conn.commit()
        output_stream.write("{i} processed rows ".format(i=processed_rows_counter))


def _get_placeholders_string(fields_list):
    placeholders_string = ""
    
    for i, val in enumerate(fields_list):
        placeholders_string += "%s"
        if i != len(fields_list) - 1:
            placeholders_string += ','

    return placeholders_string
