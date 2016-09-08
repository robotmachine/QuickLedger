# QuickLedger
## Entry creation utility for [ledger](http://ledger-cli.org/ "ledger").  

### Install
1. Download [the archive](https://github.com/robotmachine/QuickLedger/archive/v1.0.1.tar.gz)
2. Run `chmod +x ql`
3. Move `ql` to `/usr/local/bin/` or somewhere else in `$PATH`
  
 
### Configuration File  
`ql` keeps all data in `$HOME/.qlrc`  

#### [file]
The ledger_file section under [file] is created automatically during the first run wizard. 

#### [account]
Optional account section can be used to create a nickname for accounts. When specifying an account either via -a/--account or interactively, `ql` will attempt to match the entry with the nicknames in this section. If no match is found the literal input will be used. The default_account should be set to the nickname of the desired default account. 

#### [merchant] & [category]
The optional merchant and category section can be used to create nicknames and default categories for merchants. When specifying the merchant with either 
The ~/.qlrc file can be manually edited to include [merchant] nicknames. Additionally, adding a [category] section will use the matching category for that merchant nickname.
  
#### Sample ~/.qlrc
```
$> cat ~/.qlrc  
  
[file]  
ledger_file = /home/robotmachine/doc/Ledger.dat  
  
[account]
default_account = cheq 
cheq = Assets:MyCreditUnion:Chequing  
save = Assets:MyCreditUnion:Savings  
  
[merchant]  
ef = Earth Fare
pub = Publix
gas = Joe's Fuel

[category]
groc = Expenses:Groceries
ef = Expenses:Groceries  
pub = Expenses:Groceries  
gas = Expenses:Auto:Fuel  
```
  
### Usage
`ql` requires an account, a merchant name, a category, and an amount at minimum. The date will always be set to today if no date option is selected. If any required information is missing from the command line, `ql` will enter interactive mode and prompt the user for the missing data.  
  
Only one of -e/--expense or -c/--category is needed. The -e/--expense option will prepend Expenses: to the category name to save you typing. In interactive mode Expenses is prepended automatically as well.  
  
Similarly, only one of -d/--date or -r/--rdate is needed. The -d/--date option takes a YYYY-MM-DD formatted date to use as the transaction date. -r/--rdate will use today's date and then offset the provided whole positive or negative integer. A positive value goes backward and a negative value goes forward. Ie. 1 is yesterday and -1 is tomorrow.  

The -s/--split option will take the -t amount as the total (or prompt for one) and prompt through splitting the transaction between multiple categories (see example). `ql` does its best to make sure the transaction will balance and will add the total as a negative balance which will cause an error in `Ledger` if the amounts do not reconcile. Entering a 0 for any of the splits will use the remainder of the balance.  
  
The -x/--not-cleared option will use a ! instead of * between the date and the merchant as per the `Ledger` documentation to mark the transaction as not cleared. Please see `Ledger` documentation on how this works. Note: You will need to manually edit your ledger.dat file to mark it as cleared. Re-running `ql` without the -x will not mark the transaction as cleared-- it will only add an additional entry for the same amount.  

### Examples
Everyone loves examples.  
 
#### Interactive Mode
Running `ql` with no options will enter an interactive mode.  
```
$> ql
Merchant name:
        Bob's Groceries
Category:
        Expenses:Food:Groceries
Amount: $40.21

Wrote entry to /home/robotmachine/doc/Ledger.dat:
2016-02-01 * Bob's Groceries
        Expenses:Food:Groceries                 $40.21
	Assets:MyCreditUnion:Chequing  
 ```
 
#### Using Arguments
The same transaction as above, but using arguments instead of interactive.
Both lines are equivalent using the long and short version of the arguments.    
```
$> ql --merchant "Bob's Groceries" --expense "Food:Groceries" --amount 40.21
$> ql -m "Bob's Groceries" -e "Food:Groceries" -t 40.21
```
```
Wrote entry to /home/robotmachine/doc/Ledger.dat:
2016-02-01 * Bob's Groceries
        Expenses:Food:Groceries                 $40.21
	Assets:MyCreditUnion:Chequing  
```
#### Using Nicknames
The above sample .qlrc file is used for the next example.  
```
$> ql -m SD -t 27.50
```
```
Wrote entry to /home/robotmachine/doc/Ledger.dat:
2016-02-01 * Sundance Natural Foods  
	Expenses:Groceries		$27.50  
	Assets:MyCreditUnion:Chequing  
```

#### Dates
Relative date:  
(Current date in example is 2016-02-01)
```
$> ql -m "Bob's Groceries" -e "Food:Groceries" -t 40.21 -r 1
```
```
Wrote entry to /home/robotmachine/doc/Ledger.dat:
2016-01-31 * Bob's Groceries
        Expenses:Food:Groceries                 $40.21
        Assets:OSCU:Brian
```
Manual date:  
```
$> ql -m "Bob's Groceries" -e "Food:Groceries" -t 40.21 -d 2016-01-15
```
```
Wrote entry to /home/robotmachine/doc/Ledger.dat:
2016-01-15 * Bob's Groceries
        Expenses:Food:Groceries                 $40.21
        Assets:OSCU:Brian
```

#### Split Transaction
```
$> ql -m "Bob's Groceries" -t 100 --split
```
```
Total is $100.00  
Enter '0' for the remainder.  
  
Enter amount for split number 1:        $75  
Enter category for split number 1:      Expenses:Expenses:Groceries  
  
$25.00 remaining.  
Enter amount for split number 2:        $0  
Enter category for split number 2:      Expenses:Healthcare:Supplements  
  
Wrote entry to /home/robotmachine/doc/Ledger.dat:  
2016-02-01 * Bob's Groceries
        Expenses:Healthcare:Supplements        $25.00    
        Expenses:Groceries                     $75.00  
        Assets:MyCreditUnion:Chequing          $-100.00  
 ```
  
#### Transfer
Use -a/--account for where funds are coming from and -c/--category for where the funds are going to.  
Note: Account nicknames from .qlrc do not work with -c/--category
```
$> ql -m Transfer -a SAVE -c Assets:MyCreditUnion:Chequing -t 100
```
```
Wrote entry to /home/robotmachine/doc/Ledger.dat:  
2016-02-01 * Bob's Groceries
	Assets:MyCreditUnion:Chequing		$100.00
        Assets:MyCreditUnion:Savings
```
  
#### Other Examples
Credit Card Payment  
```
$> ql -m "My Credit Union" -a CHEQ -c "Liabilities:Credit:CU Visa" -t 100
```
```
Wrote entry to /home/robotmachine/doc/Ledger.dat:  
2016-02-01 * My Credit Union
        Liabilities:Credit:CU Visa                      $100.00
        Assets:MyCreditUnion:Chequing
```
Income: Getting Paid  
```
$> ql -m "My Employer" -a Income:Salary:Employer -c Assets:MyCreditUnion:Chequing -t 2140.23
```
```
Wrote entry to /home/robotmachine/doc/Ledger.dat:  
2016-02-01 * My Employer
	Assets:MyCreditUnion:Chequing			$2140.23
	Income:Salary:Employer
```

### Built-In Help
```
$> ql -h
```
```
usage: ql [-h] [-f LEDGER_FILE] [-a ACCOUNT] [-m MERCHANT] [-c CATEGORY]
          [-e EXPENSE] [-t AMOUNT] [-r RDATE] [-d DATE] [-s] [-x] [--list]
          [--set-acct] [--set-merch] [--set-cat] [--config ALT_CONFIG] [-v]

QuickLedger: Entry creation utility for http://ledger-cli.org

optional arguments:
  -h, --help            show this help message and exit
  -f LEDGER_FILE, --file LEDGER_FILE
                        Specify Ledger data file.
  -a ACCOUNT, --account ACCOUNT
                        Specify account.
  -m MERCHANT, --merchant MERCHANT
                        Set merchant.
  -c CATEGORY, --category CATEGORY
                        Set transaction category.
  -e EXPENSE, --expense EXPENSE
                        Set expense category. (Prepends 'Expenses:')
  -t AMOUNT, --amount AMOUNT
                        Set transaction amount.
  -r RDATE, --rdate RDATE
                        Set number of days ago transaction occurred. Positive
                        value for days in the past, negative value for days in
                        the future. Overrides --date.
  -d DATE, --date DATE  Set date of transaction. Format is YYYY-MM-DD.
  -s, --split           Split payment.
  -x, --not-cleared     Mark transaction as not-cleared/pending.
  --list                List settings in config file.
  --config ALT_CONFIG   Specify alternate config file.
  -v, --version         Print version.
```
