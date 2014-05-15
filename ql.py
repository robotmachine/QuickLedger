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
import os, sys, datetime, argparse, configparser

settings = os.path.expanduser("~/.qlrc")
config = configparser.ConfigParser()

def main():
	"""
	parser = argparse.ArgumentParser(description='ql: Quick Ledger entry.', prog='ql')
	parser.add_argument('-f',
		action='store', dest='file', default=None,
		help='Specify Ledger file.')
	args = parser.parse_args()
	read_config(file=args.file)
	"""
	datesel()

def datesel():
	tdateraw = []
	today = datetime.date.today()
	tdateraw.append(today)
	tdate = str(tdateraw[0])
	chooser(tdate)
	
"""
def read_config(file):
	if os.path.exists(settings):
		config.read(settings)
	chooser(file)
"""
def chooser(tdate):
	merchant = input("Merchant name: ")	
	category = input("Expense category: ")	
	amount = input("Amount: $")	
	print("%s * %s" % (tdate, merchant))
	print("\tExpenses:%s\t\t%s" % (category, amount))
	print("\tAssets:OSU:Brian")
	quit()
main()
