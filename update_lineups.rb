#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'ProgRunner'


schools = {
  "ual" => "Alabama",
  "uar" => "Arkansas",
  "uaz" => "Arizona",
  "uca" => "California",
  "uco" => "Colorado",
  "uct" => "Connecticut",
  "ude" => "Delaware",
  "ufl" => "Florida",
  "uga" => "Georgia",
  "uia" => "Iowa",
  "uid" => "Idaho",
  "uil" => "Illinois",
  "uin" => "Indiana",
  "uks" => "Kansas",
  "uky" => "Kentucky",
  "ula" => "Louisiana",
  "uma" => "Massachusetts",
  "umd" => "Maryland",
  "ume" => "Maine",
  "umi" => "Michigan",
  "umn" => "Minnesota",
  "umo" => "Missouri",
  "ums" => "Mississippi",
  "umt" => "Montana",
  "unc" => "North Carolina",
  "und" => "North Dakota",
  "une" => "Nebraska",
  "unh" => "New Hampshire",
  "unj" => "New Jersey",
  "unm" => "New Mexico",
  "unv" => "Nevada",
  "uny" => "New York",
  "uoh" => "Ohio",
  "uok" => "Oklahoma",
  "uor" => "Oregon",
  "upa" => "Pennsylvania",
  "uri" => "Rhode Island",
  "usc" => "South Carolina",
  "usd" => "South Dakota",
  "utn" => "Tennessee",
  "utx" => "Texas",
  "uut" => "Utah",
  "uva" => "Virginia",
  "uvt" => "Vermont",
  "uwa" => "Washington",
  "uwi" => "Wisconsin",
  "uwv" => "West Virginia",
  "uwy" => "Wyoming"
}


set_lineups = ProgRunner.new location, "set_lineups"

schools.each do |school,name|
  set_lineups.execute "#{school}.stat"
  if set_lineups.has_output?
    puts "#{name}:"
    puts set_lineups.get_output
    print "\n"
  end
end
