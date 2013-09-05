#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'FileParser'
require 'ScheduleParser'
require 'TeamParser'


class TeamRankings

  class TeamRating
    attr_reader :name
    attr_accessor :rating

    def initialize( name, rating )
      @name = name
      @rating = rating
    end

    def <=>( other )
      return other.rating <=> @rating
    end

    def calc_new_rating( opponent, scored, allowed )
      new_rating = @rating + (scored - allowed)

      if scored > allowed
        new_rating += 10 + (opponent.rating / 4.0).to_i
      else
        penalty = (@rating > opponent.rating) ? ((@rating - opponent.rating) / 4).to_i : 0
        new_rating -= (50 + penalty)
      end

      return new_rating
    end

  end

  def initialize
    @ratings = Hash.new
    @teams   = Array.new
  end

  def load_teams( schools )
    schools.each do |school|
      tp = TeamParser.new
      fp = FileParser.new tp

      fp.process_file "#{school}.team"

      @teams.push TeamRating.new( tp.team.name, tp.team.get_team_rating )
    end

    rank_teams
  end

  def rank_teams
    @teams.sort!

    i = 0
    @teams.each do |team|
      team.rating = 500 - (i * 10)
      @ratings.store team.name, team
      i += 1
    end
  end

  def process_schedule( filename )
    sp = ScheduleParser.new
    fp = FileParser.new sp

    fp.process_file filename

    sp.schedule.days.each do |day|
      next if ! day.completed

      day.games.each do |game|
        update_ratings game
      end
    end
  end

  def update_ratings( game )
    home = @ratings.fetch game.home_team
    road = @ratings.fetch game.road_team

    new_home_rating = home.calc_new_rating road, game.home_score, game.road_score
    new_road_rating = road.calc_new_rating home, game.road_score, game.home_score

    home.rating = new_home_rating
    road.rating = new_road_rating
  end

  def print_top_25
    teams = @ratings.values
    teams.sort!

    i = 0
    teams.each do |team|
      i += 1
      printf "%2d. %s\n", i, team.name
      break if i >= 25
    end
  end

end


if ARGV.length != 1
  abort "Usage: #{__FILE__} <filename>\n"
end

filename = ARGV[0]

if ! File.exists? filename
  abort "File '#{filename}' not found.\n"
end


schools = [ 'ual', 'uar', 'uaz', 'uca', 'uco', 'uct', 'ude', 'ufl',
            'uga', 'uid', 'uil', 'uin', 'uia', 'uks', 'uky', 'ula',
            'uma', 'umd', 'ume', 'umi', 'umn', 'umo', 'ums', 'umt',
            'unc', 'und', 'une', 'unh', 'unj', 'unm', 'unv', 'uny',
            'uoh', 'uok', 'uor', 'upa', 'uri', 'usc', 'usd', 'utn',
            'utx', 'uut', 'uva', 'uvt', 'uwa', 'uwi', 'uwv', 'uwy' ]

rankings = TeamRankings.new

rankings.load_teams schools
rankings.process_schedule filename
rankings.print_top_25
