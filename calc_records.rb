#!/usr/bin/env ruby
#
# Reads filled in schedule.csv file and calculates
# Overall, Division and Head-To-Head records as well
# as scoring totals.
location = File.dirname __FILE__

$: << "#{location}"
require 'FileParser'
require 'ScheduleParser'


class TeamRecords

  class Record
    attr_accessor :wins, :losses, :ties

    def initialize
      @wins   = 0
      @losses = 0
      @ties   = 0
    end

    def update( score, opp_score )
      if score > opp_score
        @wins += 1
      elsif score < opp_score
        @losses += 1
      else
        @ties += 1
      end
    end

    def to_s( precision = 2 )
      return sprintf "%#{precision}d-%#{precision}d-%#{precision}d", @wins, @losses, @ties
    end
  end


  def initialize
    @team_divisions = {
      'Connecticut'   => 1, 'Delaware'      => 2, 'Alabama'        => 3, 'Illinois'     => 4, 'Arizona'    => 5, 'Idaho'      => 6, 'Iowa'         => 7, 'Arkansas'    => 8,
      'Maine'         => 1, 'Maryland'      => 2, 'Florida'        => 3, 'Indiana'      => 4, 'California' => 5, 'Montana'    => 6, 'Kansas'       => 7, 'Louisiana'   => 8,
      'Massachusetts' => 1, 'New Jersey'    => 2, 'Georgia'        => 3, 'Kentucky'     => 4, 'Colorado'   => 5, 'Nebraska'   => 6, 'Minnesota'    => 7, 'Mississippi' => 8,
      'New Hampshire' => 1, 'New York'      => 2, 'North Carolina' => 3, 'Michigan'     => 4, 'Nevada'     => 5, 'Oregon'     => 6, 'North Dakota' => 7, 'Missouri'    => 8,
      'Rhode Island'  => 1, 'Virginia'      => 2, 'South Carolina' => 3, 'Ohio'         => 4, 'New Mexico' => 5, 'Washington' => 6, 'South Dakota' => 7, 'Oklahoma'    => 8,
      'Vermont'       => 1, 'West Virginia' => 2, 'Tennessee'      => 3, 'Pennsylvania' => 4, 'Utah'       => 5, 'Wyoming'    => 6, 'Wisconsin'    => 7, 'Texas'       => 8 }



    @overall  = Record.new
    @division = Record.new
    @home     = Record.new
    @road     = Record.new

    @points_scored  = 0
    @points_allowed = 0

    @opponents = Hash.new
  end

  def print_records
    printf "%s  %s  %s  %4d  %4d\n", @overall.to_s, @home.to_s, @road.to_s, @points_scored, @points_allowed

    count = 0
    @opponents.sort.each do |opponent, record|
      printf "   %15s %s", opponent, record.to_s(1)

      count += 1

      if count == 3
        print "\n"
        count = 0
      end
    end

    print "\n\n"
  end

  def update( game, is_home )
    score     = is_home ? game.home_score : game.road_score
    opp_score = is_home ? game.road_score : game.home_score
    opponent  = is_home ? game.road_team  : game.home_team

    @points_scored += score
    @points_allowed += opp_score
    @overall.update score, opp_score

    if is_home
      @home.update score, opp_score
    else
      @road.update score, opp_score
    end

    if @opponents.has_key? opponent
      record = @opponents.fetch opponent
    else
      record = Record.new
    end

    record.update score, opp_score
    @opponents.store opponent, record
  end

  def in_division?( home_team, road_team )
    if @team_divisions.has_key?( home_team ) && @team_divisions.has_key?( road_team )
      return (@team_divisions.fetch( home_team ) == @team_divisions.fetch( road_team ))
    end

    return false
  end

  def is_team?( team )
    return @team_divisions.has_key?( team )
  end
end


if ARGV.length != 1
  abort "Usage: #{__FILE__} <filename>\n"
end

filename = ARGV[0]

if ! File.exists? filename
  abort "File '#{filename}' not found.\n"
end

sp = ScheduleParser.new
fp = FileParser.new sp

fp.process_file filename

schedule = sp.schedule

team_records = Hash.new

schedule.days.each do |day|
  day.games.each do |game|
    next if ! game.played

    # road team
    if team_records.has_key? game.road_team
      team_record = team_records.fetch game.road_team
    else
      team_record = TeamRecords.new
    end

    team_record.update game, false
    team_records.store game.road_team, team_record

    # home team
    if team_records.has_key? game.home_team
      team_record = team_records.fetch game.home_team
    else
      team_record = TeamRecords.new
    end

    team_record.update game, true
    team_records.store game.home_team, team_record
  end
end

team_records.sort.each do |team, team_record|
  next if ! team_record.is_team? team
  printf "%-15s ", team
  team_record.print_records
end
