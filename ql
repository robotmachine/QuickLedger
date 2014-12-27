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
	parser.add_argument('--set-acct',
		action='store_true', dest='setacct',
		help='Set up accounts in config file.')
	parser.add_argument('--set-merch',
		action='store_true', dest='setmerch',
		help='Set up merchants in config file.')
	parser.add_argument('--set-cat',
		action='store_true', dest='setcat',
		help='Set up categories in config file.')
	parser.add_argument('--config',
		action='store', dest='alt_config', default=None,
		help='Specify alternate config file.')
	args = parser.parse_args()
	"""
	Checks if an alternate config file was specified and verifies that it exists if so.
	If not, then it will check that the default location is there ~/.qlrc
	If that isn't present, then it will run the setup.
	"""
	global settings
	if args.alt_config is not None:
		pathtest = os.path.exists(os.path.expanduser(args.alt_config))
		if pathtest is False:
			print('\n%s not found.\n' % args.alt_config)
			settings = None
		else:
			settings = os.path.expanduser(args.alt_config)
	else:
		settings = None
	if settings is None:
		settest = os.path.exists(os.path.expanduser("~/.qlrc"))
		if settest is True:
			settings = os.path.expanduser("~/.qlrc")
		else:
			settings = set_config()
	config.read(settings)
	"""
	Run setup or list if selected.
	"""
	if args.listit:
		listit()
	elif args.setacct:
		accounts()
	elif args.setmerch:
		merchants()
	elif args.setcat:
		categories()
	if args.amount:
		amount = args.amount
	split = args.split
	"""
	Determine ledger file.
	"""
	if args.ledger_file and os.path.exists(os.path.expanduser(args.ledger_file)):
		ledger_file = os.path.expanduser(args.ledger_file)
	else:
		ledger_file = read_config('ledger', None, None)
	"""
	Set merchant.
	"""
	if args.merchant is None:
		merchant = read_config('merchant', None, None)
	else:
		merchant = read_config('merchant', args.merchant, None)
	"""
	Sets category.
	"""
	if split is False:
		if args.category is None and args.expense is None:
			category = read_config('category', None, args.merchant)
		elif args.category is not None and args.expense is None:
			category = read_config('category', args.category, args.merchant)
		elif args.expense is not None:
			expcat = str('Expenses:'+str(args.expense))
			category = read_config('category', expcat, args.merchant)
		else:
			None
	"""
	Set amount.
	"""
	if args.amount is None and split is False:
		amlist = []
		catlist = []
		amlist.append(dollar_tool(query_tool('Amount: $')))
		catlist.append(str(category))
		trtotal = amlist[0]
	elif args.amount is not None and split is False:
		amlist = []
		catlist = []
		amlist.append(dollar_tool(args.amount))
		catlist.append(str(category))
		trtotal = amlist[0]
	elif args.amount is None and split is True:
		amlist, catlist, trtotal = splitter(None)
	else:
		amlist, catlist, trtotal = splitter(dollar_tool(args.amount))
	"""
	Set account.
	"""
	if args.account is None:
		account = read_config('account', None, None)
	else:
		account = read_config('account', args.account, None)
	"""
	Set date.
	See https://github.com/robotmachine/ql/issues/26
	"""
	date = datesel()

	"""
	Sets the cleared status based on -x / --not-cleared
	"""
	if args.uncleared:
		clrstat = str(' ! ')
	else:
		clrstat = str(' * ')
	"""
	"""
	ledger_entry = assembly(date, clrstat, merchant, amlist, catlist, account, trtotal)
	printer(ledger_file, ledger_entry)
	quit()

def read_config(query, varone, vartwo):
	"""
	"""
	if query == 'ledger':
		result = config['file']['ledger_file']
	elif query == 'account':
		if varone is None:
			try:
				default = config['account']['default_account']
				result = config['account'][default]
			except:
				acct_entry = str(query_tool('Account:\n\tAssets:'))
				try:
					result = config['account'][acct_entry]
				except:
					result = str('Assets:'+acct_entry)
		else:
			try:
				result = config['account'][varone]
			except:
				result = varone
	elif query == 'merchant':
		if varone is None:
			merchant = str(query_tool('Merchant name:\n\t'))
			try:
				result = config['merchant'][merchant]
			except:
				result = merchant
		else:
			try:
				result = config['merchant'][varone]
			except:
				result = varone
	elif query == 'category':
		try:
			result = config['category'][vartwo]
		except:
			if varone is None:
				cat_entry = str(query_tool('Category:\n\tExpenses:'))
				try:
					result = config['category'][cat_entry]
				except:
					result = str('Expenses:'+cat_entry)
			else:
				try:
					result = config['category'][varone]
				except:
					result = varone
	return result

def datesel():
	tdateraw = []
	today = datetime.date.today()
	tdateraw.append(today)
	tdate = str(tdateraw[0])
	return tdate

def splitter(amount):
	if amount is None:
		total = dollar_tool(query_tool('\nTotal dollar amount for entry: $'))
	else:
		total = amount
		print('\nTotal is $%.2f' % total)
	latot = total
	counter = 0
	amlist = []
	catlist = []
	print("Enter '0' for the remainder.")
	while latot is not None:
		counter = counter + 1
		splitamount = dollar_tool(query_tool('\nEnter amount for split number %i:\t$' % counter))
		cat_entry = query_tool('\nEnter category for split number %i:\tExpenses:' % counter)
		try:
			splitcat = config['category'][cat_entry]
		except:
			splitcat = str('Expenses:'+cat_entry)
		if splitamount == 0.00:
			amlist.append(latot)
			catlist.append(splitcat)
			latot = 0.00
		else:
			amlist.append(splitamount)
			catlist.append(splitcat)
			latot = latot - splitamount
		if latot == 0.00:
			latot = None
		elif latot < 0.00:
			print('Transaction does not balance.')
			amlist = []
			catlist = []
			amount = total
			splitter(amount)
		else:
			print('\n$%.2f remaining.' % latot)
	counter = counter - 1
	return amlist, catlist, total

def assembly(date, clrstat, merchant, amlist, catlist, account, trtotal):
	ledger_list = []
	ledger_list.append(date)
	ledger_list.append(clrstat)
	ledger_list.append(merchant)
	ledger_list.append('\n')
	counter = len(amlist) - 1
	while counter >= 0:
		ledger_list.append('\t')
		ledger_list.append(str(catlist[counter]))
		ledger_list.append('\t\t$')
		ledger_list.append(str(amlist[counter]))
		ledger_list.append('\n')
		counter = counter - 1
	ledger_list.append('\t')
	ledger_list.append(account)
	if len(amlist) > 1:
		ledger_list.append('\t\t$-')
		ledger_list.append(str(trtotal))
	ledger_list.append('\n')
	result = ''.join(ledger_list)
	return result

def printer(ledger_file, ledger_entry):
	try:
		with open(ledger_file, "a") as ledger_write:
			ledger_write.write(ledger_entry)
			print('\n\nWrote entry to '+ledger_file+':\n'+ledger_entry)
	except PermissionError:
		print("Cannot write to %s. Permission error!" % ledger_file)
	except:
		print('Something went wrong.')
		quit()
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
		defaultq = config['account']['default_account']
	except:
		defaultq = None
	if defaultq is None:
		boolquery = bool_tool("\nWould you like to set this as the default account? [y/N]: ")
		if boolquery == True:
			makedefault = True
		else:
			makedefault = False
	elif defaultq is not None:
		defaultqq = config['account'][defaultq]
		boolquery = bool_tool("\nThe current default account is "+defaultqq+"\nWould you like to replace it with this one? [Y/n] ")
		if boolquery == True:
			makedefault = True
		else:
			makedefault = False

	config.set('account',shortname,acctname)
	if makedefault == True:
		config.set('account','default_account',shortname)
	with open(settings, 'w') as configfile:
		config.write(configfile)
	quit()

def merchants():
	nickname = query_tool('\nEnter a short name for the merchant: ')
	merchname = query_tool('\nEnter the full merchant name: ')
	boolquery = bool_tool("\nWould you like to enter a default category for this merchant? [y/N] ")
	if boolquery == True:
		merchcat = query_tool('\nEnter a default category for '+merchname+': ')
	else:
		merchcat = False

	if os.path.exists(settings):
		config.read(settings)
	else:
		print('No .qlrc file found. Creating ~/.qlrc')

	config ['merchant'] = {nickname: merchname}
	try:
		with open(settings, 'w') as configfile:
			config.write(configfile)
			print('Merchant written to %s' % settings)
	except PermissionError:
		print('\nERROR:\nUnable to write settings to %s' % settings)
		quit()
	except:
		print('Something went wrong.')
		quit()
	if merchcat:
		config ['category'] = {nickname: merchcat}
		try:
			with open(settings, 'w') as configfile:
				config.write(configfile)
				print('Category written to %s' % settings)
		except PermissionError:
			print('\nERROR:\nUnable to write settings to %s' % settings)
			quit()
		except:
			print('Something went wrong.')
			quit()
	quit()

def categories():
	nickname = query_tool('\nEnter a short name for the category: ')
	catname = query_tool('\nEnter the full category: ')

	if os.path.exists(settings):
		config.read(settings)
	else:
		print('No .qlrc file found. Creating ~/.qlrc')

	config ['category'] = {nickname: catname}
	try:
		with open(settings, 'w') as configfile:
			config.write(configfile)
			print('Settings written to %s' % settings)
	except PermissionError:
		print('\nERROR:\nUnable to write settings to %s' % settings)
		quit()
	except:
		print('Something went wrong.')
		quit()
	quit()

def listit():
	try:
		config.read(settings)
	except:
		print('\nERROR:\nNo config file found. Run some kind of setup.')
		quit()
	try:
		print('\nMerchants\n')
		for conffile in config['merchant']:
			print(conffile+'\t = '+config['merchant'][conffile])
	except:
		print('\nNo merchants found in %s.\n' % settings)
	try:
		print('\nAccounts')
		print(config['account']['default_account']+' is the default account.\n')
		for conffile in config['account']:
			if conffile != "default_account":
				print(conffile+"\t = "+config['account'][conffile])
	except:
		print('\nNo accounts found in %s.\n' % settings)
	quit()

def set_config():
	settings = os.path.expanduser('~/.qlrc')
	"""
	Checks for both $LEDGER and $LEDGER_FILE environment variables.
	Sets system_ledger to their value if they exist.
	"""
	try:
		if os.path.exists(os.path.expanduser(os.environ['LEDGER'])):
			system_ledger = os.path.expanduser(os.environ['LEDGER'])
		elif os.path.exists(os.path.expanduser(os.environ['LEDGER_FILE'])):
			system_ledger = os.path.expanduser(os.environ['LEDGER_FILE'])
		else:
			system_ledger = None
	except:
		system_ledger = None

	"""
	Asks if the above value should be set as the default file for `ql'
	"""
	if system_ledger is not None: 
		print("Default Ledger file detected as %s" % system_ledger)
		boolquery = bool_tool("Use this file for ql? [y/N] ")
		if boolquery is True:
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
		led_input = query_tool('Enter Ledger file location: ')
		if os.path.exists(os.path.expanduser(led_input)):
			led_file = os.path.expanduser(led_input)
		else:
			print('\nERROR:\nLedger file not found: %s' % led_input)
			quit()
	"""
	Checks again to make sure the ledger_file actually exists.
	If it does, then it writes that value to .qlrc in the $HOME folder.
	"""	
	if os.path.isfile(led_file):
		config ['file'] = {'ledger_file': led_file}
		try:
			with open(settings, 'w') as configfile:
				config.write(configfile)
				print('Settings written to %s' % settings)
		except PermissionError:
			print('\nERROR:\nUnable to write settings to %s' % settings)
			quit()
		except:
			print('Something went wrong.')
			quit()
	else:
		print('\nERROR:\nLedger file not found: %s' % led_file)
	return settings

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
