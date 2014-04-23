from utils import exec_shell


def _db_params_to_args(params):
    """Return connection arguments for CLI tools, excluding database name."""
    return "-h{hostname} -U{username}".format(hostname=params['host'],
                                              username=params['username'])


def _db_params_to_args_name(params):
    return _db_params_to_args(params) + " " + params['name']


def check_db_existence(params):
    """Return True if database exists."""

    cmd = "psql " + _db_params_to_args(params) + " -lqt | cut -d \| -f 1 | grep -w {db_name}".format(db_name=params['name'])
    return exec_shell(cmd)


def create_database(params):
    cmd = "createdb" + " " + _db_params_to_args_name(params)
    return exec_shell(cmd)


def drop_database(params):
    cmd = "dropdb" + " " + _db_params_to_args_name(params)
    return exec_shell(cmd)
