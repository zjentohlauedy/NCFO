#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'FileParser'
require 'TeamParser'

if ARGV.length != 1
  abort "Usage: #{__FILE__} <filename>\n"
end

filename = ARGV[0]

if ! File.exists? filename
  abort "File '#{filename}' not found.\n"
end

tp = TeamParser.new
fp = FileParser.new tp

fp.process_file filename

team = tp.team

printf "'%s' => [ %6.4f, %6.4f, %6.4f ],\n", team.name,
team.get_average_team_rating,
team.get_average_lineup_rating( ".LO" ),
team.get_average_lineup_rating( ".LD" )
