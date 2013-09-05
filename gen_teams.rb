#!/usr/bin/env ruby
#
$location = File.dirname __FILE__

$: << "#{$location}"
require 'Team'


if ARGV.length != 1
  abort "Usage: #{__FILE__} <filename>\n"
end

filename = ARGV[0]

if ! File.exists? filename
  abort "File '#{filename}' not found.\n"
end



teams = {
  'ual' => [ 'Alabama',        'Crimson Tide',    [  9,  0,  0 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  9,  0,  0 ] ],
  'uar' => [ 'Arkansas',       'Razorbacks',      [ 12,  1,  3 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 12,  1,  3 ] ],
  'uaz' => [ 'Arizona',        'Sun Devils',      [  8,  0,  0 ], [ 15, 13,  0 ], [ 15, 15, 15 ], [  8,  0,  0 ] ],
  'uca' => [ 'California',     'Golden Bears',    [  1,  1,  7 ], [ 15, 13,  1 ], [ 15, 15, 15 ], [  1,  1,  7 ] ],
  'uco' => [ 'Colorado',       'Buffalos',        [  0,  0,  0 ], [ 12, 11,  7 ], [ 12, 12, 12 ], [  0,  0,  0 ] ],
  'uct' => [ 'Connecticut',    'Huskies',         [  0,  2,  6 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  0,  2,  6 ] ],
  'ude' => [ 'Delaware',       'Blue Hens',       [  4,  6, 14 ], [ 15, 15,  0 ], [ 15, 15, 15 ], [  4,  6, 14 ] ],
  'ufl' => [ 'Florida',        'Gators',          [  0,  2, 10 ], [ 15,  4,  0 ], [ 15, 15, 15 ], [  0,  2, 10 ] ],
  'uga' => [ 'Georgia',        'Bulldogs',        [ 15,  0,  0 ], [  0,  0,  0 ], [ 15, 15, 15 ], [ 15,  0,  0 ] ],
  'uid' => [ 'Idaho',          'Vandals',         [  0,  0,  0 ], [ 12, 11,  7 ], [ 12, 12, 12 ], [  0,  0,  0 ] ],
  'uil' => [ 'Illinois',       'Fighting Illini', [ 15,  6,  0 ], [  0,  3,  6 ], [ 15, 15, 15 ], [  0,  3,  6 ] ],
  'uin' => [ 'Indiana',        'Hoosiers',        [  9,  0,  0 ], [ 15, 15, 12 ], [ 15, 15, 12 ], [  9,  0,  0 ] ],
  'uia' => [ 'Iowa',           'Hawkeyes',        [  0,  0,  0 ], [ 12, 11,  3 ], [ 15, 15, 15 ], [  0,  0,  0 ] ],
  'uks' => [ 'Kansas',         'Jayhawks',        [  0,  2, 12 ], [ 14,  0,  0 ], [ 15, 15, 15 ], [  0,  2, 12 ] ],
  'uky' => [ 'Kentucky',       'Wildcats',        [  0,  4,  7 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  0,  4,  7 ] ],
  'ula' => [ 'Louisiana',      'Ragin Cajuns',    [  4,  1,  7 ], [ 15, 13,  2 ], [ 15, 15, 15 ], [  4,  1,  7 ] ],
  'uma' => [ 'Massachusetts',  'Minutemen',       [  8,  0,  0 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  8,  0,  0 ] ],
  'umd' => [ 'Maryland',       'Terrapins',       [ 12,  1,  2 ], [  0,  0,  0 ], [ 15, 15, 15 ], [  0,  0,  0 ] ], # Also Gold: 15, 13, 1
  'ume' => [ 'Maine',          'Black Bears',     [  0,  2,  4 ], [  7, 11, 14 ], [ 15, 15, 15 ], [  0,  2,  4 ] ],
  'umi' => [ 'Michigan',       'Wolverines',      [  0,  3,  6 ], [ 15, 13,  3 ], [ 15, 15, 15 ], [  0,  3,  6 ] ],
  'umn' => [ 'Minnesota',      'Golden Gophers',  [  8,  0,  0 ], [ 15, 13,  0 ], [ 15, 15, 15 ], [  8,  0,  0 ] ],
  'umo' => [ 'Missouri',       'Tigers',          [  0,  0,  0 ], [ 15, 12,  3 ], [ 15, 15, 15 ], [  0,  0,  0 ] ],
  'ums' => [ 'Mississippi',    'Rebels',          [ 12,  1,  2 ], [  0,  2,  6 ], [ 15, 15, 15 ], [ 12,  1,  2 ] ],
  'umt' => [ 'Montana',        'Grizzlies',       [  6,  0,  3 ], [  9,  9,  9 ], [  9,  9,  9 ], [  6,  0,  3 ] ],
  'unc' => [ 'North Carolina', 'Tarheels',        [  5, 10, 13 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  5, 10, 13 ] ],
  'und' => [ 'North Dakota',   'Fighting Sioux',  [  0, 10,  0 ], [  0,  0,  0 ], [ 15, 15, 15 ], [  0, 10,  0 ] ],
  'une' => [ 'Nebraska',       'Corn Huskers',    [ 15,  2,  0 ], [ 15, 15, 13 ], [ 15, 15, 13 ], [ 15,  2,  0 ] ],
  'unh' => [ 'New Hampshire',  'Big Green',       [  0,  6,  3 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  0,  6,  3 ] ],
  'unj' => [ 'New Jersey',     'Scarlet Knights', [ 12,  0,  1 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 12,  0,  1 ] ],
  'unm' => [ 'New Mexico',     'Lobos',           [ 13,  0,  3 ], [ 12, 12, 12 ], [ 12, 12, 12 ], [ 13,  0,  3 ] ],
  'unv' => [ 'Nevada',         'Wolf Pack',       [  0,  0,  8 ], [ 12, 12, 12 ], [ 12, 12, 12 ], [  0,  0,  8 ] ],
  'uny' => [ 'New York',       'Bobcats',         [  4,  2,  6 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  4,  2,  6 ] ],
  'uoh' => [ 'Ohio',           'Buckeyes',        [ 15,  2,  0 ], [ 10, 10, 10 ], [ 10, 10, 10 ], [ 15,  2,  0 ] ],
  'uok' => [ 'Oklahoma',       'Sooners',         [  9,  0,  1 ], [ 15, 15, 13 ], [ 15, 15, 13 ], [  9,  0,  1 ] ],
  'uor' => [ 'Oregon',         'Ducks',           [  0,  6,  6 ], [ 15, 13,  0 ], [ 15, 15, 15 ], [  0,  6,  6 ] ],
  'upa' => [ 'Pennsylvania',   'Nittany Lions',   [  1,  2,  5 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  1,  2,  5 ] ],
  'uri' => [ 'Rhode Island',   'Rams',            [  8, 12, 15 ], [  0,  0,  8 ], [ 15, 15, 15 ], [  8, 12, 15 ] ],
  'usc' => [ 'South Carolina', 'Gamecocks',       [  8,  2,  3 ], [  0,  0,  0 ], [ 15, 15, 15 ], [  0,  0,  0 ] ],
  'usd' => [ 'South Dakota',   'Coyotes',         [ 14,  4,  3 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 14,  4,  3 ] ],
  'utn' => [ 'Tennessee',      'Volunteers',      [ 15,  7,  0 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 15,  7,  0 ] ],
  'utx' => [ 'Texas',          'Longhorns',       [ 12,  5,  0 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 12,  5,  0 ] ],
  'uut' => [ 'Utah',           'Utes',            [ 12,  0,  0 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 12,  0,  0 ] ],
  'uva' => [ 'Virginia',       'Cavaliers',       [ 15,  6,  0 ], [  0,  0,  8 ], [ 15, 15, 15 ], [  0,  0,  8 ] ],
  'uvt' => [ 'Vermont',        'Catamounts',      [  0,  6,  3 ], [ 12, 12,  0 ], [ 15, 15, 15 ], [  0,  6,  3 ] ],
  'uwa' => [ 'Washington',     'Cougars',         [  9,  1,  3 ], [  6,  6,  7 ], [ 15, 15, 15 ], [  9,  1,  3 ] ],
  'uwi' => [ 'Wisconsin',      'Badgers',         [ 12,  1,  2 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 12,  1,  2 ] ],
  'uwv' => [ 'West Virginia',  'Mountaineers',    [ 15, 12,  0 ], [  0,  3,  6 ], [ 15, 15, 15 ], [  0,  3,  6 ] ],
  'uwy' => [ 'Wyoming',        'Cowboys',         [  4,  2,  2 ], [ 15, 12,  2 ], [ 15, 15, 15 ], [  4,  2,  2 ] ]
}


def create_playbook( team )
  offense = File.read "#{$location}/ncfo_offense.pb"
  defense = File.read "#{$location}/ncfo_defense#{team.defense}.pb"

  File.write "#{team.abbr}.pb", offense + defense
end

def create_gameplan( team )
  File.write "#{team.abbr}.gp", File.read( "#{$location}/ncfo_#{team.determine_style}.gp" )
end


player_names = File.read( filename ).split /\n/


teams.each do |abbr, values|
  team = Team.new

  team.abbr               = abbr
  team.name               = values[0]
  team.nickname           = values[1]
  team.colors.home_jersey = values[2]
  team.colors.home_letter = values[3]
  team.colors.road_jersey = values[4]
  team.colors.road_letter = values[5]

  print "Generating #{team.name} (#{team.abbr}.team)\n"

  team.generate_team player_names
  team.set_lineups
  team.write_team

  create_playbook team
  create_gameplan team
end

File.write filename, player_names.join( "\n" ) + "\n"
