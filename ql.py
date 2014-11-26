#!/usr/bin/env python3
"""
 =-=-=- ql -=-=-=
 | Quick Ledger |
 |    v.0.5     |
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

""" Settings are stored in .qlrc in user's home folder. """
settings = os.path.expanduser("~/.qlrc")
config = configparser.ConfigParser()

def main():
	"""
	Reads arguments and puts things where they go.
	"""
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
	parser.add_argument('--set-acct',
		action='store_true', dest='set_acct',
		help="Add accounts to ql's configuration file.")
	args = parser.parse_args()
	if args.set_acct:
		set_account()
	category = args.category
	ledger_file = args.ledger_file
	account = args.account
	merchant = args.merchant
	read_config(ledger_file, account, merchant, category)

def read_config(ledger_file, account, merchant, category):
	"""
	If a settings file is specified on the command line, then just skip to the 
	actual ledger entry. If not, ql checks for the file. If it is there, then 
	ql reads from it. If there is no settings file and no file was specified, then
	we move to set up the config file.	
	"""
	if os.path.exists(settings):
		config.read(settings)
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

		if os.path.isfile(ledger_file):
			datesel(ledger_file, account, merchant, category)
		else:
			print("Error! Cannot find %s" % ledger_file)
	else:
		set_config(account, merchant, category)

def set_config(account, merchant, category):
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
		query = input("Use this file for ql? [y/n] ")
		try:
			boolquery = distutils.util.strtobool(query)
		except:
			print("Must enter yes or no.")
			set_config(account)
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
		led_input = input("Ledger file location: ")
		led_file = os.path.expanduser(led_input)	
		if not os.path.isfile(led_file):
			print("File not found.")
			quit()	
	"""
	Checks again to make sure the ledger_file actually exists.
	If it does, then it writes that value to .qlrc in the $HOME folder.
	"""	
	if os.path.isfile(led_file):
		config ['file'] = {'ledger_file': led_file}
		with open(settings, 'w') as configfile:
			config.write(configfile)
		read_config(led_file, account, merchant, category)

def set_account():
	print("You are a star.")
	quit()

def datesel(ledger_file, account, merchant, category):
	tdateraw = []
	today = datetime.date.today()
	tdateraw.append(today)
	tdate = str(tdateraw[0])
	merchsel(ledger_file, account, merchant, category, tdate)

def merchsel(ledger_file, account, merchant, category, tdate):
	if merchant is None:
		try:
			merchant = str(input("Merchant name:\n\t"))
		except KeyboardInterrupt:
			user_exit()
		except:
			print("Syntax error.")
			merchsel(ledger_file, account, merchant, tdate)
	else:
		merchant = str(merchant)
	if category is None:
		try:
			category = str("Expenses:")+str(input("Expense category:\n\tExpenses:"))
		except KeyboardInterrupt:
			user_exit()
		except:
			print("Syntax error.")
			merchsel(ledger_file, account, merchant, tdate)
	else:
		category = str(category)
	if account is None:
		try:
			account = str("Assets:")+str(input("Account:\n\tAssets:"))
		except KeyboardInterrupt:
			user_exit()
		except:
			print("Syntax error.")
			merchsel(ledger_file, account, merchant, tdate)
	amountsel(ledger_file, tdate, merchant, category, account)

def amountsel(ledger_file, tdate, merchant, category, account):
	try:
		amount_dec = Decimal(input("Amount: $")).quantize(Decimal('1.00'))
	except KeyboardInterrupt:
		user_exit()
	except: 
		print("Amount must be a number.")
		amountsel(ledger_file, tdate, merchant, category, account)
	amount = str(amount_dec)
	printer(ledger_file, tdate, merchant, category, account, amount)

def printer(ledger_file, tdate, merchant, category, account, amount):
	ledger_entry = tdate+" * "+merchant+"\n\t"+category+"\t\t$"+amount+"\n\t"+account+"\n"
	try:
		with open(ledger_file, "a") as ledger_write:
			ledger_write.write(ledger_entry)
			ledger_write.close()
			print("\n\nWrote entry to "+ledger_file+":\n\n"+ledger_entry)
	except PermissionError:
		print("Cannot write to %s. Permission error!" % ledger_file)
	quit()
def user_exit():
	print("\nUser exited.")
	quit()
main()
