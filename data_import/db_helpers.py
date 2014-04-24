from utils import exec_shell


def _make_db_args(params):
    """Return connection arguments for CLI tools, excluding database name."""
    return "-h{hostname} -U{username}".format(hostname=params['host'],
                                              username=params['username'])


def _make_db_args_name(params):
    return _make_db_args(params) + " " + params['name']


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


def copy_csvfile_to_table(file, table_name, db_params):
    pass
