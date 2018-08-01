# frozen_string_literal: true

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
