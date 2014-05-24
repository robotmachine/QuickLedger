#!/usr/bin/env python3
"""
=-=-=- ql -=-=-=
| Quick Ledger |
=-=-=-=-=-=-=-=-
*
* Brian Carter
* robotmachine@gmail.com
* https://github.com/robotmachine/ql
*
* This program is free software. It comes without any warranty, to
* the extent permitted by applicable law. You can redistribute it
* and/or modify it under the terms of the Do What The Fuck You Want
* To Public License, Version 2, as published by Sam Hocevar. See
* http://sam.zoy.org/wtfpl/COPYING for more details.
"""
import os, sys, textwrap, datetime, argparse, configparser

settings = os.path.expanduser("~/.qlrc")
config = configparser.ConfigParser()

def main():
	parser = argparse.ArgumentParser(description='ql: Quick Ledger entry.', prog='ql')
	parser.add_argument('-f',
		action='store', dest='file', default=None,
		help='Specify Ledger file.')
	args = parser.parse_args()
	read_config(file=args.file)

def query_yes_no(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.

    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
        It must be "yes" (the default), "no" or None (meaning
        an answer is required of the user).

    The "answer" return value is one of "yes" or "no".
    """
    valid = {"yes":True,   "y":True,  "ye":True,
             "no":False,     "n":False}
    if default == None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = raw_input().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' "\
                             "(or 'y' or 'n').\n")

def read_config(file):
	if file is None:
		if os.path.exists(settings):
			config.read(settings)
		if not os.path.exists(settings):
			set_config()
	else:
		datesel(file)

def set_config():
	if os.environ['LEDGER']:
		system_ledger = str(os.environ['LEDGER'])
	elif os.environ['LEDGER_FILE']:
		system_ledger = str(os.environ['LEDGER_FILE'])
	if system_ledger:
		print(textwrap.dedent("""
		Looks like your default ledger file is
		%s
		Use that for ql?	
		""") % (system_ledger))
		file = system_ledger
	else:
		file = input("Ledger file location: ")
	datesel(file)
		

def datesel(file):
	tdateraw = []
	today = datetime.date.today()
	tdateraw.append(today)
	tdate = str(tdateraw[0])
	chooser(file, tdate)
	
def chooser(file, tdate):
	merchant = input("Merchant name: ")	
	category = input("Expense category: ")	
	amount = input("Amount: $")	
	print("%s" % (file))
	print("%s * %s" % (tdate, merchant))
	print("\tExpenses:%s\t\t$%s" % (category, amount))
	print("\tAssets:OSU:Brian")
	quit()
main()
