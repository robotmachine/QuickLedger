# ql

## Quick entry creation tool for [Ledger](http://ledger-cli.org/ "Ledger").  

### Usage
>`ql` with no arguments for account or nickname will read the account listed as default. Running `ql --nick SAVE` will use the account nicknamed SAVE from qlrc.
>usage: ql [-h] [-f LEDGER_FILE] [-a ACCOUNT] [-m MERCHANT] [--set-acct]
>
>ql: Quick `ledger' entry creation tool.
>
>optional arguments:
>  -h, --help            show this help message and exit
>  -f LEDGER_FILE, --file LEDGER_FILE
>                        Specify Ledger file.
>  -a ACCOUNT, --account ACCOUNT
>                        Specify account from ql's configuration file.
>  -m MERCHANT, --merchant MERCHANT
>                        Set merchant.
>  --set-acct            Add accounts to ql's configuration file.
