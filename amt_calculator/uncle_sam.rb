# frozen_string_literals: true

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
