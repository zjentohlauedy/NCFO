#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'FileParser'
require 'ProgRunner'
require 'ScheduleParser'

if ARGV.length != 1
  abort "Usage: #{__FILE__} <schedule.csv>\n"
end

filename = ARGV[0]

if ! File.exists? filename
  abort "File '#{filename}' not found.\n"
end

schools = {
  "Alabama"        => "ual",
  "Arkansas"       => "uar",
  "Arizona"        => "uaz",
  "California"     => "uca",
  "Colorado"       => "uco",
  "Connecticut"    => "uct",
  "Delaware"       => "ude",
  "Florida"        => "ufl",
  "Georgia"        => "uga",
  "Iowa"           => "uia",
  "Idaho"          => "uid",
  "Illinois"       => "uil",
  "Indiana"        => "uin",
  "Kansas"         => "uks",
  "Kentucky"       => "uky",
  "Louisiana"      => "ula",
  "Massachusetts"  => "uma",
  "Maryland"       => "umd",
  "Maine"          => "ume",
  "Michigan"       => "umi",
  "Minnesota"      => "umn",
  "Missouri"       => "umo",
  "Mississippi"    => "ums",
  "Montana"        => "umt",
  "North Carolina" => "unc",
  "North Dakota"   => "und",
  "Nebraska"       => "une",
  "New Hampshire"  => "unh",
  "New Jersey"     => "unj",
  "New Mexico"     => "unm",
  "Nevada"         => "unv",
  "New York"       => "uny",
  "Ohio"           => "uoh",
  "Oklahoma"       => "uok",
  "Oregon"         => "uor",
  "Pennsylvania"   => "upa",
  "Rhode Island"   => "uri",
  "South Carolina" => "usc",
  "South Dakota"   => "usd",
  "Tennessee"      => "utn",
  "Texas"          => "utx",
  "Utah"           => "uut",
  "Virginia"       => "uva",
  "Vermont"        => "uvt",
  "Washington"     => "uwa",
  "Wisconsin"      => "uwi",
  "West Virginia"  => "uwv",
  "Wyoming"        => "uwy"
}

sp = ScheduleParser.new
fp = FileParser.new sp
rankings = ProgRunner.new location, "rankings.rb"
leaders = ProgRunner.new location, "leaders.rb"
lineups = ProgRunner.new location, "update_lineups.rb"
copy = ProgRunner.new "/bin", "cp"

fp.process_file filename

schedule = sp.schedule

week     = nil
schedule.days.each do |day|
  break if ! day.completed
  week = day
end

exit if week.nil?

puts "Week: #{week.day}"


week_folder = sprintf "W%02d", week.day

puts "Copying stat files to #{week_folder}/"
Dir.mkdir week_folder

Dir.glob("*.stat").each do |file|
  copy.execute file, week_folder
end


rankings_file = sprintf "week%02d_top25.txt", week.day

puts "Generating Top 25 to #{rankings_file}"
rankings.execute filename
File.write rankings_file, rankings.get_output


leaders_file = sprintf "week%02d_leaders.txt", week.day

puts "Computing League Leaders to #{leaders_file}"
leaders.execute
File.write leaders_file, leaders.get_output


injuries_file = sprintf "week%02d_injuries.txt", week.day

puts "Writing Injury Reports to #{injuries_file}"
output = "Injury Reports:\n"
lineups.execute
if lineups.has_output?
  output += lineups.get_output
end
File.write injuries_file, output


puts "Changing directory into #{week_folder}"
Dir.chdir week_folder

standouts = ProgRunner.new "../#{location}", "standouts.rb"
boxscores = ProgRunner.new "../#{location}", "print_boxscores"

if week.day == 1
  stat_ext = "stat"
else
  stat_ext = "statx"

  gen_statx = ProgRunner.new "../#{location}", "gen_statx.sh"
  last_week_dir = sprintf "../W%02d", week.day - 1

  puts "Computing stats for week #{week.day} from #{last_week_dir}"
  gen_statx.execute last_week_dir
end


standouts_file = sprintf "week%02d_standouts.txt", week.day

puts "Computing Standouts to ../#{standouts_file}"
standouts.execute stat_ext
File.write "../#{standouts_file}", standouts.get_output


puts "Compiling Box Scores:"
week.games.each do |game|
  roadstats = schools.fetch game.road_team
  homestats = schools.fetch game.home_team

  boxscore_file = sprintf "W%02dG%02d.txt", week.day, game.number

  puts "Saving #{game.road_team} @ #{game.home_team} to #{boxscore_file}"
  boxscores.execute "#{roadstats}.#{stat_ext}", "#{homestats}.#{stat_ext}"
  File.write boxscore_file, boxscores.get_output
end
