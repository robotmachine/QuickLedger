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
import os, sys, textwrap, datetime, argparse, configparser, distutils.util

""" Settings are stored in .qlrc in user's home folder. """
settings = os.path.expanduser("~/.qlrc")
config = configparser.ConfigParser()

def main():
	"""
	Reads command line arguments to determine if a file is specified.		
	"""
	parser = argparse.ArgumentParser(description='ql: Quick Ledger entry.', prog='ql')
	parser.add_argument('-f',
		action='store', dest='ledger_file', default=None,
		help='Specify Ledger file.')
	args = parser.parse_args()
	read_config(ledger_file=args.ledger_file)

def read_config(ledger_file):
	"""
	If a settings file is specified on the command line, then just skip to the 
	actual ledger entry. If not, ql checks for the file. If it is there, then 
	ql reads from it. If there is no settings file and no file was specified, then
	we move to set up the config file.	
	"""
	if ledger_file is None:
		if os.path.exists(settings):
			config.read(settings)
			ledger_file = config['ql']['ledger_file']
			datesel(ledger_file)
		else:
			set_config()
	else:
		datesel(ledger_file)

def set_config():
	if os.environ['LEDGER']:
		system_ledger = os.path.expanduser(os.environ['LEDGER'])
	elif os.environ['LEDGER_FILE']:
		system_ledger = os.path.expanduser(os.environ['LEDGER_FILE'])
	else:
		system_ledger = None
	if system_ledger is not None: 
		print(textwrap.dedent("""
		Looks like your default ledger file is
		%s
		""") % (system_ledger))
		file = system_ledger
	else:
		file = input("Ledger file location: ")
	datesel(file)

def datesel(ledger_file):
	tdateraw = []
	today = datetime.date.today()
	tdateraw.append(today)
	tdate = str(tdateraw[0])
	chooser(ledger_file, tdate)
	
def chooser(ledger_file, tdate):
	merchant = input("Merchant name: ")	
	category = input("Expense category: ")	
	amount = input("Amount: $")	
	print("%s" % (file))
	print("%s * %s" % (tdate, merchant))
	print("\tExpenses:%s\t\t$%s" % (category, amount))
	print("\tAssets:OSU:Brian")
	quit()
main()
