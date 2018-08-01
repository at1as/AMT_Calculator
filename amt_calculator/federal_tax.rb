# frozen_string_literal: true

module FederalTax
  YEAR                = 2018
  INF                 = Float::INFINITY
  STANDARD_DEDUCTION  = 12_000
  
  TAX_BRACKETS = [
    [0..9_525,            0.10],
    [9_526..38_700,       0.12],
    [38_701..82_500,      0.22],
    [82_501..157_500,     0.24],
    [157_501..200_000,    0.32],
    [200_001..500_000,    0.35],
    [500_001..INF,        0.37]
  ]

  def FederalTax.calculate_income_tax(income, iso_gains, rsu_income, pension, verbose)
    adjusted_income = income + rsu_income - pension - STANDARD_DEDUCTION
    puts "Taxable income after standard deduction: $" + adjusted_income.to_s if verbose

    TAX_BRACKETS.inject(0) do |sum, (range, percent)|
      reached_current_tax_bracket = range.min < adjusted_income
      bracket_taxable_rate        = range.min > adjusted_income ? 0 : percent
      floor_of_tax_bracket        = range.min
      ceiling_of_tax_bracket      = range.max > adjusted_income ? adjusted_income : range.max
      taxable_income_in_bracket   = ceiling_of_tax_bracket - floor_of_tax_bracket

      if reached_current_tax_bracket
        puts "Adding $#{taxable_income_in_bracket * bracket_taxable_rate} to federal taxes from #{range} tax bracket at #{percent*100} %"
        sum + (taxable_income_in_bracket * bracket_taxable_rate)
      else
        puts "No additional taxes in the #{range} tax bracket at #{percent*100} %" if verbose
        sum
      end
    end
  end
end
