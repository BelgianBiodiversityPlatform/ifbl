import psycopg2
import os
import csv
from tempfile import mkstemp

from jinja2 import Environment, FileSystemLoader

from utils import exec_shell, chunks

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


# filename: full path to filename of the SQL templates
# context: variable substitution (templating)
def load_sqltemplate(filename, context, db_params):
    # Render SQL template to temporary file
    j2_env = Environment(loader=FileSystemLoader('/'), trim_blocks=True)
    r = j2_env.get_template(filename).render(context)
    fd, temp_path = mkstemp()
    os.write(fd, r)
    os.close(fd)

    # Load rendered version to Postgres
    return_of_load = load_sqlfile(temp_path, db_params)
    # Remove temporary file
    os.remove(temp_path)

    return return_of_load


def load_sqlfile(filename, db_params):
    cmd = "psql {host_user} -d {db} -f {filename}".format(
        host_user=_make_db_args(db_params),
        db=db_params['name'],
        filename=filename)
    
    return exec_shell(cmd)


# dict keys: field name
# dict value: value to insert
# TODO: Check it's in use?
def insert_dict_row(table_name, d, db_params):
    with DBConnection(db_params) as conn:
        cur = conn.cursor()

        # keys and vals will have the same order
        keys = []
        vals = []
        for k, v in d.iteritems():
            keys.append(k)
            vals.append(v)

        s = _get_insert_string(table_name, keys)
        cur.execute(s, tuple(vals))
        conn.commit()


def insert_many(table_name, fields_list, all_values, db_params):
    with DBConnection(db_params) as conn:
        cur = conn.cursor()
        
        s = _get_insert_string(table_name, fields_list)

        for vals in chunks(all_values, 500):
            cur.executemany(s, vals)

        conn.commit()


def copy_csvfile_to_table(f, table_name, delimiter, output_stream, db_params):
    with DBConnection(db_params) as conn:
        cur = conn.cursor()

        # cur.copy_from is shitty() (quotes, error messages, ...)
        # so we have to reinvent the wheel
        # UGLY UGLY UGLY (but works)
        input_file = csv.DictReader(f, delimiter=delimiter)

        processed_rows_counter = 0
        fields_list = []
        all_values = []

        for row in input_file:
            values = ()
            for k, v in row.iteritems():
                if processed_rows_counter == 0:  # Only needed once!
                    fields_list.append(k)

                values = values + (v,)

            all_values.append(values)
            processed_rows_counter += 1

        s = _get_insert_string(table_name, fields_list)

        for vals in chunks(all_values, 500):
            cur.executemany(s, vals)

        #if cur.rowcount != 1:
        #    output_stream.write("ERROR: rowcount is {rowcount} for {query}\n".format(rowcount=cur.rowcount, query=s))

        conn.commit()
        output_stream.write("{i} processed rows ".format(i=processed_rows_counter))


def _get_insert_string(table_name, fields_list):
    quoted_field_list = [('"' + f + '"') for f in fields_list]

    return ("INSERT INTO " + table_name + " ({fields})".format(fields=','.join(quoted_field_list)) +
            " VALUES (" + _get_placeholders_string(quoted_field_list) + ")")


def _get_placeholders_string(fields_list):
    placeholders_string = ""
    
    for i, val in enumerate(fields_list):
        placeholders_string += "%s"
        if i != len(fields_list) - 1:
            placeholders_string += ','

    return placeholders_string
