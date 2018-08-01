# AMT Calculator

Taxes are tough. The math behind them, however, isn't. It shouldn't be so difficult to get a vague idea of whether you'll owe AMT in advance of tax day.

As I couldn't find a satisfactory AMT calculator online (with reliable outputs), I've endevoured to build one. Issues, PRs, feedback are all encouraged.


### Usage

Modify the values in `tax_details.json` to fit your tax situation:
```
{
	"income":           222222, 	// Income + all taxable benefits (cafateria food, etc). Do not include RSUs here.
	"iso_share_gains":   44444,		// The `value` of RSUs vested (ignore the withholding taxes and state their full value)
	"rsu_income":        33333,		// The net gains of ISO shares
	"pension":           11111,		// The quantity you put into a 401k this fiscal year (do not include employer contributions)
	"verbose":            true		// Whether to print details of the calculations
}
```

And then run the script
```
$ ruby run.rb

*** AMT Calculator 0.0.1 ***

Note: this is a script which seeks only to provide insight into broad tax trends.
The output will be unreliable and does not provide any legal or tax advice.
Consult a tax lawyer to discuss your situtation.

---- TAX INPUTS ----
Income: $222222
ISO Gains: $44444
RSU Income: $33333
401K: $11111

---- FEDERAL TAX ----
Taxable income after standard deduction: $232444
Adding $952.5 to federal taxes from 0..9525 tax bracket at 10.0 %
Adding $3500.8799999999997 to federal taxes from 9526..38700 tax bracket at 12.0 %
Adding $9635.78 to federal taxes from 38701..82500 tax bracket at 22.0 %
Adding $17999.76 to federal taxes from 82501..157500 tax bracket at 24.0 %
Adding $13599.68 to federal taxes from 157501..200000 tax bracket at 32.0 %
Adding $11355.05 to federal taxes from 200001..500000 tax bracket at 35.0 %
No additional taxes in the 500001..Infinity tax bracket at 37.0 %

= $57043.64

---- AMT ----
AMT adjusted income: $288888
Adjusted income retains full exemption. Taxed at 26% up to $191500 and at 28% beyond

= $58780.64

---- OUTCOME ---
You owe AMT this year (which is $1736.99 greater than the standard tax)
```


### Limitations

* Uses the standard deduction for federal taxes, not itemized deductions
* Only handles `single` filing status
* Only works for updated 2018 tax laws
* Does not pretty print currency or handle their precision correctly
* Messy code base violates single responsibility principle in several places


### Outstanding Questions

* Does the Standard Deduction subtract from the top tax brackets or the bottom? (assumed bottom in this script)

### Legal

This script will, at best, provide insight into broad tax trends. It is overwhelmingly likely to contain bugs, over simplistic approximations, and misinterpretations of tax laws. Consult a tax lawyer to discuss your tax sitation.

### License

MIT
