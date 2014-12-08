# ql
### Quick entry creation tool for [Ledger](http://ledger-cli.org/ "Ledger").  

#### Install
Clone the repository, `chmod +x ql` and move ql somewhere in your $PATH.  
  
#### Usage
The first time you run `ql` it will try to figure out where your Ledger data  
file is located based on `$LEDGER` and `$LEDGER_FILE` environment variables   
and store this in a ~/.qlrc file. If nothing is found, it will just ask you.  
```
usage: ql [-h] [-f LEDGER_FILE] [-a ACCOUNT] [-m MERCHANT] [-c CATEGORY]
          [-e EXPENSE] [-t AMOUNT] [-s] [-x] [--list] [--setup-accounts]
          [--setup-merchants] [--config ALT_CONFIG]

ql: Quick `ledger' entry creation tool.

optional arguments:
  -h, --help            show this help message and exit
  -f LEDGER_FILE, --file LEDGER_FILE
                        Specify Ledger file.
  -a ACCOUNT, --account ACCOUNT
                        Specify account from ql's configuration file.
  -m MERCHANT, --merchant MERCHANT
                        Set merchant.
  -c CATEGORY, --category CATEGORY
                        Set category.
  -e EXPENSE, --expense EXPENSE
                        Set category. Automatically prepends Expenses:
  -t AMOUNT, --amount AMOUNT
                        Set dollar amount.
  -s, --split           Split payment.
  -x, --not-cleared     Marks transaction as not cleared.
  --list                List details from .qlrc
  --setup-accounts      Set up accounts in config file.
  --setup-merchants     Set up accounts in config file.
  --config ALT_CONFIG   Specify alternate config file.
```
  
#### Configuration File  
`ql` keeps all data in `$HOME/.qlrc`  
Here is a sample of what one might look like:  
`$> cat ~/.qlrc`  
  
```
[file]  
ledger_file = /home/robotmachine/doc/Ledger.dat  
[acct]
default_account = CHEQ 
CHEQ = Assets:MyBank:Chequing  
SAVE = Assets:MyBank:Savings  
[merc]  
SD = Sundance Natural Foods  
SD_CAT = Expenses:Groceries  
SQ = SeQUential Biofuels  
SQ_CAT = Expenses:Auto:Fuel  
```
  
When using the `ql -a ACCOUNT` option, `ql` will attempt to match the entry  
with one of the accounts in the [acct] section of .qlrc  
If a match is not found, the literal string will be used.  
The same is true of the `ql -m MERCHANT` option.  
If a match is found for the merchant and merchant_CAT is present, then  
merchant_CAT will be used. If that does not match, then it will prompt  
interactively for an expense category.  

#### Examples
Everyone loves examples. The above .qlrc file is assumed for the examples.  
`ql -m SD -t 27.50` will append the following to /home/robotmachine/doc/Ledger.dat  
```
2014-11-01 * Sundance Natural Foods  
	Expenses:Groceries		$27.50  
	Assets:MyBank:Chequing  
```
