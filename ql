#!/usr/bin/env python3
"""
 =-=-=- ql -=-=-=
 | Quick Ledger |
 |    v.0.7     |
 =-=-=-=-=-=-=-=-

©2014 Brian A. Carter
robotmachine@gmail.com
https://github.com/robotmachine/ql

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
import os, sys, textwrap, datetime, argparse, configparser, distutils.util
from decimal import *

global config
config = configparser.ConfigParser()

def main():
	parser = argparse.ArgumentParser(description="ql: Quick `ledger' entry creation tool.", prog='ql')
	args = parser.parse_args()
	parser.add_argument('-f', '--file',
		action='store', dest='ledger_file', default=None,
		help='Specify Ledger file.')
	parser.add_argument('-a', '--account',
		action='store', dest='account', default=None,
		help="Specify account from ql's configuration file.")
	parser.add_argument('-m', '--merchant',
		action='store', dest='merchant', default=None,
		help='Set merchant.')
	parser.add_argument('-c', '--category',
		action='store', dest='category', default=None,
		help='Set category.')
	parser.add_argument('-e', '--expense',
		action='store', dest='expense', default=None,
		help='Set category. Automatically prepends Expenses:')
	parser.add_argument('-t', '--amount',
		action='store', dest='amount', default=None,
		help='Set dollar amount.')
	parser.add_argument('-s', '--split',
		action='store_true', dest='split', default=False,
		help='Split payment.',)
	parser.add_argument('-x', '--not-cleared',
		action='store_true', dest='uncleared',
		help='Marks transaction as not cleared.')
	parser.add_argument('--list',
		action='store_true', dest='listit',
		help='List details from .qlrc')
	parser.add_argument('--setup-accounts',
		action='store_true', dest='setacct',
		help='Set up accounts in config file.')
	parser.add_argument('--setup-merchants',
		action='store_true', dest='setmerch',
		help='Set up accounts in config file.')
	parser.add_argument('--config',
		action='store', dest='alt_config', default=None,
		help='Specify alternate config file.')
	"""
	"""
	global clrstat
	if args.uncleared:
		clrstat = str("!")
	else:
		clrstat = str("*")
	"""
	"""
	global settings
	setpath = os.path.expanduser("~/.qlrc")
	if os.path.exists(setpath):
	settings = setpath
	global settings
	if args.alt_config is not None:
		if '~' in args.alt_config:
			try:
				expset = os.path.expanduser(args.alt_config)
				if os.path.exists(expset):
					settings = expset
			except:
				if os.path.exists(args.alt_config):
					settings = args.alt_config
		else:
			if os.path.exists(args.alt_config):
				settings = args.alt_config
	else:
		alt_config = None
	"""
	"""
	category = args.category
	if args.expense:
		category = str('Expenses:'+str(args.expense))
	"""
	"""
	ledger_file = str(args.ledger_file)
	amount = args.amount
	account = args.account
	merchant = args.merchant
	"""
	"""
	global split
	split = args.split
	"""
	"""
	if args.listit:
		listit()
	elif args.setacct:
		accounts()
	elif args.setmerch:
		merchants()
	read_config(ledger_file, account, merchant, category, amount)

def read_config(ledger_file, account, merchant, category, amount):
	"""
	If a settings file is specified on the command line, then just skip to the 
	actual ledger entry. If not, ql checks for the file. If it is there, then 
	ql reads from it. If there is no settings file and no file was specified, then
	we move to set up the config file.	
	"""
	if os.path.exists(settings):
		config.read(settings)
	else:
		set_config(account, merchant, category, amount)

	if ledger_file is None:
		try:
			ledger_file = config['file']['ledger_file']
		except:
			ledger_file = None
	if account is None:
		try:
			account = config['acct']['default_account']
		except:
			account = None
	if account is not None:
		try:
			account = config['acct'][account]
		except:
			account = account
	if merchant is not None:
		try:
			category = config['merc'][merchant+'_CAT']
			merchant = config['merc'][merchant]
		except:
			merchant = merchant	
	ledger_user = os.path.expanduser(ledger_file)
	if os.path.isfile(ledger_file):
		None
	elif os.path.expanduser(ledger_user):
		ledger_file = ledger_user
	else:
		print("Error! Cannot find %s" % ledger_file)
		quit()
	datesel(ledger_file, account, merchant, category, amount)

def datesel(ledger_file, account, merchant, category, amount):
	tdateraw = []
	today = datetime.date.today()
	tdateraw.append(today)
	tdate = str(tdateraw[0])
	merchsel(ledger_file, account, merchant, category, amount, tdate)

def merchsel(ledger_file, account, merchant, category, amount, tdate):

	if merchant is None:
		merchant = str(query_tool("Merchant name:\n\t"))
	else:
		merchant = str(merchant)

	if category is None:
		catlist = ['str("Expenses:")+str(query_tool("Expense category:\n\tExpenses:"))']
	else:
		catlist = ['str(category)']

	if account is None:
		account = str("Assets:")+str(query_tool("Account:\n\tAssets:"))
	else:
		account = str(account)

	amountsel(ledger_file, tdate, merchant, catlist, amount, account)

def amountsel(ledger_file, tdate, merchant, catlist, amount, account):
	if split is False:
		if amount is None:
			amount_dec = dollar_tool(query_tool('Amount: $'))
		elif amount is not None:
			amount_dec = dollar_tool(amount)
		amlist = [str(amount_dec)]
		printer(ledger_file, tdate, merchant, catlist, account, amlist)
	else:
		if amount is None:
			total = dollar_tool(query_tool('Total dollar amount for the entry: $'))
		else:
			total = dollar_tool(amount)
			print("Total is $",total)
		latot = total
		counter = 0
		amlist = []
		catlist = []
		while latot is not None:
			counter = counter + 1
			splitamount = dollar_tool(query_tool('\nEnter amount for split number %i: $' % counter))
			splitcat = query_tool('\nEnter category for split number %i: ' % counter)
			amlist.append(splitamount)
			catlist.append(str(splitcat))
			latot = latot - splitamount
			if latot == 0.00:
				latot = None
			elif latot < 0.00:
				print("Transaction doesn't balance.")
				amlist = []
				catlist = []
				amount = total
				amountsel(ledger_file, tdate, merchant, category, amount, account)
			else:
				print('\n$%.2f remaining.' % latot)
		counter = counter - 1
		while counter >= 0:
			print('\t'+str(catlist[counter])+"\t\t"+str(amlist[counter]))
			counter = counter - 1
		quit()

def printer(ledger_file, tdate, merchant, category, account, amount):
	ledger_entry = tdate+" "+clrstat+" "+merchant+"\n\t"+category+"\t\t$"+amount+"\n\t"+account+"\n"
	try:
		with open(ledger_file, "a") as ledger_write:
			ledger_write.write(ledger_entry)
			ledger_write.close()
			print("\n\nWrote entry to "+ledger_file+":\n\n"+ledger_entry)
	except PermissionError:
		print("Cannot write to %s. Permission error!" % ledger_file)
	quit()

def accounts():
	shortname = query_tool('\nEnter a short name for the account: ')
	acctname = 'Assets:'+query_tool('\nEnter the account name:  Assets:')
	fullacct = shortname+" = "+acctname
	if os.path.exists(settings):
		config.read(settings)
	else:
		print('No .qlrc file found. Creating ~/.qlrc')

	try:
		defaultq = config['acct']['default_account']
	except:
		defaultq = None
	if defaultq is None:
		boolquery = bool_tool("\nWould you like to set this as the default account? [y/N]: ")
		if boolquery == True:
			makedefault = True
		else:
			makedefault = False
	elif defaultq is not None:
		defaultqq = config['acct'][defaultq]
		boolquery = bool_tool("\nThe current default account is "+defaultqq+"\nWould you like to replace it with this one? [Y/n] ")
		if boolquery == True:
			makedefault = True
		else:
			makedefault = False

	config.set('acct',shortname,acctname)
	if makedefault == True:
		config.set('acct','default_account',shortname)
	with open(settings, 'w') as configfile:
		config.write(configfile)
	quit()

def merchants():
	nickname = query_tool('\nEnter a short name for the merchant: ')
	merchname = query_tool('\nEnter the full merchant name: ')
	merchentry = nickname+" = "+merchname
	boolquery = bool_tool("\nWould you like to enter a default category for this merchant? [y/N] ")
	if boolquery == True:
		nickcat = nickname+"_CAT"
		merchcat = query_tool("\nEnter a default category for "+merchname+": ")
	else:
		merchcat = False

	if os.path.exists(settings):
		config.read(settings)
	else:
		print('No .qlrc file found. Creating ~/.qlrc')

	config.set('merc',nickname,merchname)
	if merchcat:
		config.set('merc',nickcat,merchcat)
	with open(settings, 'w') as configfile:
		config.write(configfile)
	quit()

def listit():
	if os.path.exists(settings):
		config.read(settings)
	else:
		print("No config file found. Run some kind of setup.")
	try:
		print("\nMerchants\n")
		for conffile in config['merc']:
			print(conffile+"\t = "+config['merc'][conffile])
	except:
		print("\nNo merchants found.\n")
	print("\nAccounts\n")
	try:
		print(config['acct']['default_account']+' is the default account.\n')
		for conffile in config['acct']:
			if conffile != "default_account":
				print(conffile+"\t = "+config['acct'][conffile])
	except:
		print("\nNo accounts found.\n")
	quit()

def set_config(account, merchant, category, amount):
	"""
	Checks for both $LEDGER and $LEDGER_FILE environment variables.
	Sets system_ledger to their value if they exist.
	"""
	try:
		if os.environ['LEDGER']:
			system_ledger = os.path.expanduser(os.environ['LEDGER'])
		elif os.environ['LEDGER_FILE']:
			system_ledger = os.path.expanduser(os.environ['LEDGER_FILE'])
	except:
		system_ledger = None

	"""
	Asks if the above value should be set as the default file for `ql'
	"""
	if system_ledger is not None: 
		print(textwrap.dedent("""
		Looks like your default ledger file is
		%s
		""") % (system_ledger))
		boolquery = bool_tool("Use this file for ql? [y/N] ")
		if boolquery == True:
			led_file = system_ledger
		else:
			led_file = None
	else:
		led_file = None
	"""
	If either the $LEDGER and $LEDGER_FILE variables are empty or the user
	declines to use their value, it will request that the file be typed in manually.
	If the file is not found, an error will print.
	"""
	if led_file is None:
		led_input = query_tool('Ledger file location: ')
		led_file = os.path.expanduser(led_input)	
		if not os.path.isfile(led_file):
			print('File not found.')
			quit()	
	"""
	Checks again to make sure the ledger_file actually exists.
	If it does, then it writes that value to .qlrc in the $HOME folder.
	"""	
	if os.path.isfile(led_file):
		config ['file'] = {'ledger_file': led_file}
		with open(settings, 'w') as configfile:
			config.write(configfile)
		read_config(led_file, account, merchant, category, amount)

def user_exit():
	print("\nUser exited.")
	quit()

def query_tool(query):
	try:
		result = input(query)
		return result
	except KeyboardInterrupt:
		user_exit()
	except:
		print("\nSyntax error.")
		quit()

def bool_tool(query):
	bquery = query_tool(query)
	try:
		result = bool(distutils.util.strtobool(bquery))
		return result
	except:
		result = False
		return result

def dollar_tool(query):
	try:
		result = Decimal(query).quantize(Decimal('1.00'))
	except KeyboardInterrupt:
		user_exit()
	except InvalidOperation:
		print('\nMust be a number.')
		quit()
	except:
		print('\nSyntax error.')
		quit()
	return result
main()
