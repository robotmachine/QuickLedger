# ql

## Quick entry creation tool for [Ledger](http://ledger-cli.org/ "Ledger").  

### Usage
>usage: ql [-h] [-f LEDGER_FILE] [-a ACCOUNT] [-n NICKNAME]  
>    
>ql: Quick `ledger' entry creation tool.  
>  
>optional arguments:  
>  -h, --help            show this help message and exit  
>  -f LEDGER_FILE, --file LEDGER_FILE  
>                        Specify Ledger file.  
>  -a ACCOUNT, --account ACCOUNT  
>                        Specify account.  
>  -n NICKNAME, --nick NICKNAME  
>                        Specify account from qlrc by nickname.  

### Example qlrc file

>[ql]  
>ledger_file = /home/robotmachine/Doc/Ledger/Ledger.dat  
>default = BANK  
>BANK = Assets:Bank:Personal  
>SAVE = Assets:Bank:Savings  
  
`ql` with no arguments for account or nickname will read the account listed as default. Running `ql --nick SAVE` will use the account nicknamed SAVE from qlrc.
