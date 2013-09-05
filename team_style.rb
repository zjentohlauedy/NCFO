#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'FileParser'
require 'TeamParser'

tp = TeamParser.new
fp = FileParser.new tp

fp.process_file ARGV[0]

team = tp.team

rbs = []
wrs = []

team.players.each do |player|
  if player.is_running_back
    rbs.push player
  end

  if player.is_receiver
    wrs.push player
  end
end

rbs.sort! { |a,b| b.rating <=> a.rating }
wrs.sort!

rbs.slice! 2..-1
wrs.slice! 2..-1

rbavg = (rbs[0].rating + rbs[1].rating) / 2.0
wravg = (wrs[0].rating + wrs[1].rating) / 2.0

#printf "Team      RB1  RB2  AVG  -  WR1  WR1  AVG  Style\n"
printf " %s:  %3.1f  %3.1f  %3.1f  -  %3.1f  %3.1f  %3.1f  %s\n", ARGV[0],
rbs[0].rating, rbs[1].rating, rbavg,
wrs[0].rating, wrs[1].rating, wravg,
team.determine_style
