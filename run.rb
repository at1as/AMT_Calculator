# frozen_string_literal: true

puts <<LEGAL
  
  Note: this is a script which seeks only to provide insight into broad tax trends.
  The output will be unreliable and does not provide any legal or tax advice.
  Consult a tax lawyer to discuss your situtation.
LEGAL

module FederalTax
  YEAR = 2018
  INF  = Float::INFINITY
  STANDARD_DEDUCTION = 12_000
  
  BRACKETS = [
    [0..9_525,            0.10],
    [9_526..38_700,       0.12],
    [38_701..82_500,      0.22],
    [82_501..157_500,     0.24],
    [157_501..200_000,    0.32],
    [200_001..500_000,    0.35],
    [500_001..INF,        0.37]
  ]

  def FederalTax.calculate_income_tax(income, iso_gains, rsu_income, pension, verbose)
    # ISO Gains are fully deductable under standard federal income tax
    adjusted_income = income + rsu_income - pension - STANDARD_DEDUCTION
    puts "Taxable income after standard deduction: $" + adjusted_income.to_s if verbose

    BRACKETS.inject(0) do |sum, (range, percent)|
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

module AMT
  YEAR        = 2018
  LOWER_RATE  = 0.26
  HIGHER_RATE = 0.28
  
  BRACKET_CROSSOVER = 191_500
  EXEMPTION_AMOUNT  = 70_300
  PHASE_OUT_INCOME  = 500_000
  PHASE_OUT_PERCENT = 0.25

  def AMT.reduced_exemption_amount(income)
    reduced_exemptions = EXEMPTION_AMOUNT - ((income - PHASE_OUT_INCOME) * PHASE_OUT_PERCENT)
    reduced_exemptions.positive? ? reduced_exemptions : 0
  end

  def AMT.calculate_alternate_minimum_tax_owed(income, iso_gains, rsu_income, pension, verbose)
    adjusted_income = income + rsu_income + iso_gains - pension
    puts "AMT adjusted income: $" + adjusted_income.to_s if verbose

    case adjusted_income
      when -Float::INFINITY..EXEMPTION_AMOUNT
        puts "Adjusted income below exemption amount: $" + EXEMPTION_AMOUNT.to_s if verbose
        0
      
      when EXEMPTION_AMOUNT..BRACKET_CROSSOVER
        puts "Adjusted income retains full exemption. Taxed at 26% past exemption ($#{EXEMPTION_AMOUNT})" if verbose
        (adjusted_income - EXEMPTION_AMOUNT) * LOWER_RATE
      
      when BRACKET_CROSSOVER..PHASE_OUT_INCOME
        puts "Adjusted income retains full exemption. Taxed at 26% up to $#{BRACKET_CROSSOVER} and at 28% beyond"
        ((BRACKET_CROSSOVER - EXEMPTION_AMOUNT) * LOWER_RATE) + ((adjusted_income - BRACKET_CROSSOVER) * HIGHER_RATE)
      
      else
        reduced_exemptions = reduced_exemption_amount(adjusted_income)
        puts "Adjusted income subject to reduced exemption ($#{reduced_exemptions}). Taxed at 26% and 28% beyond #{BRACKET_CROSSOVER}"
        ((BRACKET_CROSSOVER - reduced_exemptions) * LOWER_RATE) + ((adjusted_income - BRACKET_CROSSOVER) * HIGHER_RATE)
    end
  end
end

class UncleSam 
  include AMT
  include FederalTax

  def initialize(income, iso_gains: 0, rsu_income: 0, pension: 0, verbose: false)
    @income     = income
    @iso_gains  = iso_gains
    @rsu_income = rsu_income
    @pension    = pension
    @verbose    = verbose

    state_of_affairs if @verbose
  end

  def state_of_affairs
    puts ?\n
    puts "---- TAX INPUTS ----"
    puts "Income: $"     + @income.to_s
    puts "ISO Gains: $"  + @iso_gains.to_s
    puts "RSU Income: $" + @rsu_income.to_s
    puts "401K: $"       + @pension.to_s
  end

  def hit_me_with_amt
    puts "Warning: These AMT tax brackets are for the #{Time.now.year} tax year" if Time.now.year.to_i > AMT::YEAR
    AMT::calculate_alternate_minimum_tax_owed(@income, @iso_gains, @rsu_income, @pension, @verbose)      
  end

  def hit_me_with_federal_tax
    puts "Warning: Theses federal income tax brackets are for the #{Time.now.year} tax year" if Time.now.year.to_i > FederalTax::YEAR
    FederalTax::calculate_income_tax(@income, @iso_gains, @rsu_income, @pension, @verbose)
  end
end


# Include taxable benefits under income (such as catered food)
income      = 222_222
rsu_income  = 33_333
iso_gains   = 44_444
pension     = 11_111

accountant = UncleSam.new(income, iso_gains: iso_gains, rsu_income: rsu_income, pension: pension, verbose: true)

puts "\n---- FEDERAL TAX ---- \n" 
standard_tax = accountant.hit_me_with_federal_tax
puts "\n= $" + standard_tax.to_s

puts "\n---- AMT ---- \n"
amt_tax = accountant.hit_me_with_amt
puts "\n= $" + amt_tax.to_s

puts "\n---- OUTCOME --- \n"
puts "You owe AMT this year (which is $#{amt_tax - standard_tax} greater than the standard tax)" if amt_tax > standard_tax
puts "You'll pay standard tax this year" if standard_tax >= amt_tax
puts ?\n

