#!/usr/bin/env python3
"""
=-=-=- ql -=-=-=
| Quick Ledger |
|    v.0.5     |
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
from decimal import *

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
		query = input("Use this file for ql? [y/n] ")
		boolquery = distutils.util.strtobool(query)
		if boolquery == True:
			led_file = system_ledger
		else:
			led_input = input("Ledger file location: ")
			led_file = os.path.expanduser(led_input)	
			if not os.path.isfile(led_file):
				print("File not found.")
				quit()	
	if os.path.isfile(led_file):
		config ['ql'] = {'ledger_file': led_file}
		with open(settings, 'w') as configfile:
			config.write(configfile)
		read_config(led_file)

def datesel(ledger_file):
	tdateraw = []
	today = datetime.date.today()
	tdateraw.append(today)
	tdate = str(tdateraw[0])
	amountsel(ledger_file, tdate)

def amountsel(ledger_file, tdate):
	try:
		amount_dec = Decimal(input("Amount: $")).quantize(Decimal('1.00'))
	except: 
		print("Amount must be a number.")
		amountsel(ledger_file, tdate)
	amount = str(amount_dec)
	printer(ledger_file, tdate, amount)

def printer(ledger_file, tdate, amount):
	merchant = input("Merchant name: ")	
	category = input("Expense category: ")	
	with open(ledger_file, "a") as ledger_write:
		ledger_write.write(tdate+" * "+merchant+"\n\tExpenses:"+category+"\t\t$"+amount+"\n\tAssets:OSU:Brian"+"\n")
		ledger_write.close()
	quit()
main()
