import subprocess
import sys


def exec_shell(cmd):
    """Exectute the passed command in a shell and return True if RC = 0."""
    rc = subprocess.call(cmd, shell=True)
    return rc == 0


def make_action_or_exit(action_description, output_stream, func, *func_args, **func_kwargs):
    """ Print action_description, call func (with args) and exit if it evaluates to False."""
    output_stream.write(acolors.BOLD + action_description + acolors.ENDC)
    if not func(*func_args, **func_kwargs):
        output_stream.write(acolors.FAIL + "ERROR" + acolors.ENDC)
        output_stream.write("\n")
        sys.exit()
    output_stream.write(acolors.OKGREEN + "DONE" + acolors.ENDC)
    output_stream.write("\n")


def chunks(l, n):
    """ Yield successive n-sized chunks from l.
    """
    for i in xrange(0, len(l), n):
        yield l[i:i + n]


# From http://code.activestate.com/recipes/410692/
# Python's lack of a 'switch' statement has garnered much discussion and even a PEP. The most
# popular substitute uses dictionaries to map cases to functions, which requires lots of defs
# or lambdas. While the approach shown here may be O(n) for cases, it aims to duplicate C's original
#'switch' functionality and structure with reasonable accuracy.

# This class provides the functionality we want. You only need to look at
# this if you want to know how this works. It only needs to be defined
# once, no need to muck around with its internals.
class switch(object):
    def __init__(self, value):
        self.value = value
        self.fall = False

    def __iter__(self):
        """Return the match method once, then stop"""
        yield self.match
        raise StopIteration
    
    def match(self, *args):
        """Indicate whether or not to enter a case suite"""
        if self.fall or not args:
            return True
        elif self.value in args:  # changed for v1.5, see below
            self.fall = True
            return True
        else:
            return False


# ANSI color class
# Usage: print bcolors.WARNING + "This is a warning message" + bcolors.ENDC
class acolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'

    BOLD = "\033[1m"
    ENDC = '\033[0m'
