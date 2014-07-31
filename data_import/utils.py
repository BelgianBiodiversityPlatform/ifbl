import subprocess
import sys


def exec_shell(cmd):
    """Exectute the passed command in a shell and return True if RC = 0."""
    rc = subprocess.call(cmd, shell=True)
    return rc == 0


def make_action_or_exit(action_description, output_stream, func, *func_args, **func_kwargs):
    """ Print action_description, call func (with args) and exit if it evaluates to False."""
    output_stream.write(action_description)
    if not func(*func_args, **func_kwargs):
        output_stream.write("ERROR")
        sys.exit()
    output_stream.write("DONE")
    output_stream.write("\n")


def chunks(l, n):
    """ Yield successive n-sized chunks from l.
    """
    for i in xrange(0, len(l), n):
        yield l[i:i + n]
