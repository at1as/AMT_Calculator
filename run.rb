# frozen_string_literal: true

require_relative 'amt_calculator/amt'
require_relative 'amt_calculator/federal_tax'
require_relative 'amt_calculator/uncle_sam'
require_relative 'amt_calculator/version'
require 'json'

puts <<~LEGAL
  \n*** AMT Calculator #{Version::VERSION} ***
  \nNote: this is a script which seeks only to provide insight into broad tax trends.
  The output will be unreliable and does not provide any legal or tax advice.
  Consult a tax lawyer to discuss your situtation.
LEGAL

tax_details = JSON.load(File.read("./tax_details.json"))

accountant = UncleSam.new(
  tax_details['income'],
  iso_gains:  tax_details['iso_share_gains'],
  rsu_income: tax_details['rsu_income'],
  pension:    tax_details['pension'],
  verbose:    tax_details['verbose']
)

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

