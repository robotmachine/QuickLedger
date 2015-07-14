# ql
### Quick entry creation tool for [Ledger](http://ledger-cli.org/ "Ledger").  

#### Install
1. Download [the archive](https://github.com/robotmachine/ql/tarball/master)
2. Move `ql` to `/usr/local/bin/` or somewhere else in `$PATH`
3. Run `chmod +x ql`
  
#### Usage
The first time you run `ql` it will try to figure out where your Ledger data file is located based on `$LEDGER` and `$LEDGER_FILE` environment variables and store this in a ~/.qlrc file. If nothing is found, it will just ask you.  
```
usage: ql [-h] [-f LEDGER_FILE] [-a ACCOUNT] [-m MERCHANT] [-c CATEGORY]
          [-e EXPENSE] [-t AMOUNT] [-s] [-x] [--list] [--set-acct]
          [--set-merch] [--set-cat] [--config ALT_CONFIG]

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
  --set-acct            Set up accounts in config file.
  --set-merch           Set up merchants in config file.
  --set-cat             Set up categories in config file.
  --config ALT_CONFIG   Specify alternate config file.
```
  
#### Configuration File  
`ql` keeps all data in `$HOME/.qlrc`  
Here is a sample of what one might look like:  
`$> cat ~/.qlrc`  
  
```
[file]  
ledger_file = /home/robotmachine/doc/Ledger.dat  
  
[account]
default_account = CHEQ 
CHEQ = Assets:MyBank:Chequing  
SAVE = Assets:MyBank:Savings  
  
[merchant]  
SD = Sundance Natural Foods  
SQ = SeQUential Biofuels  

[category]
groc = Expenses:Groceries
SD = Expenses:Groceries  
SQ = Expenses:Auto:Fuel  
```
The ~/.qlrc file can be manually edited or you can use the various setup options, --set-acct, --set-cat, --set-merch to have `ql` add them to ~/.qlrc for you.  
  
#### Usage Continued
When using the `ql -a ACCOUNT` option, `ql` will attempt to match the entry with one of the accounts in the [account] section of ~/.qlrc If a match is not found, the literal string will be used.  
  
The same is true of the `ql -m MERCHANT` option. If a match is found for the merchant and the same entry is present under [category], then the category will be used. If that does not match, then it will prompt interactively for an expense category.  
  
The -s/--split option will take the -t amount as the total (or prompt for one) and prompt through splitting the transaction between multiple categories (see example). `ql` does its best to make sure the transaction will balance and will add the total as a negative balance which will cause an error in `Ledger` if the amounts do not reconcile. Entering a 0 for any of the splits will use the remainder of the balance.  
  
The -x/--not-cleared option will use a ! instead of * between the date and the merchant as per the `Ledger` documentation to mark the transaction as not cleared. Please see `Ledger` documentation on how this works. Note: You will need to manually edit your ledger.dat file to mark it as cleared. Re-running `ql` without the -x will not mark the transaction as cleared-- it will only add an additional entry for the same amount.  

#### Examples
Everyone loves examples. The above .qlrc file is assumed for the examples.  
  
`ql -m SD -t 27.50` will append the following to /home/robotmachine/doc/Ledger.dat  
```
2014-11-01 * Sundance Natural Foods  
	Expenses:Groceries		$27.50  
	Assets:MyBank:Chequing  
```
##### Split Transaction
`ql -m SD -t 100`
```
Total is $100.00  
Enter '0' for the remainder.  
  
Enter amount for split number 1:        $75  
Enter category for split number 1:      Expenses:Expenses:Groceries  
  
$25.00 remaining.  
Enter amount for split number 2:        $0  
Enter category for split number 2:      Expenses:Heathcare:Supplements  
  
Wrote entry to /home/robotmachine/doc/Ledger.dat:  
2014-12-27 * Sundance Natural Foods 
        Expenses:Heathcare:Supplements  $25.00    
        Expenses:Groceries              $75.00  
        Assets:MyBank:Chequing          $-100.00  
```
