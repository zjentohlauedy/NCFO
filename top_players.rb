#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'FileParser'
require 'TeamParser'


class TeamPlayer
  attr_reader :team, :player

  def initialize( team, player )
    @team   = team
    @player = player
  end

  def <=>( other )
    return other.player.rating <=> @player.rating
  end

  def to_s
    sprintf "%s %-20s %-15s %1.1f", @player.position, @player.name, @team, @player.rating
  end

end


class StatRankings

  def initialize( schools )
    @schools = schools
    @teams   = Array.new
    @players = Array.new

    load_teams
  end

  def load_teams
    @schools.each do |school|
      tp = TeamParser.new
      fp = FileParser.new tp

      fp.process_file "#{school}.team"

      @teams.push tp.team
    end
  end

  def process_categories( categories )
    categories.each do |key, value|
      compile_stats value.fetch 'positions'

      print "#{value.fetch 'label'}\n"
      print_top_players
      print "\n"
    end
  end

  def compile_stats( positions )
    @players = Array.new

    @teams.each do |team|
      team.players.each do |player|
        if positions.include? player.position
          @players.push TeamPlayer.new( team.name, player )
        end
      end
    end
  end

  def print_top_players( count=15 )
    @players.sort!

    i = 0

    while i < [count, @players.length].min
      print "#{@players[i].to_s}\n"
      i += 1
    end
  end

end


schools = [ 'ual', 'uar', 'uaz', 'uca', 'uco', 'uct', 'ude', 'ufl',
            'uga', 'uid', 'uil', 'uin', 'uia', 'uks', 'uky', 'ula',
            'uma', 'umd', 'ume', 'umi', 'umn', 'umo', 'ums', 'umt',
            'unc', 'und', 'une', 'unh', 'unj', 'unm', 'unv', 'uny',
            'uoh', 'uok', 'uor', 'upa', 'uri', 'usc', 'usd', 'utn',
            'utx', 'uut', 'uva', 'uvt', 'uwa', 'uwi', 'uwv', 'uwy' ]

categories = {
  'quarterbacks'   => { 'positions' => ['QB'            ], 'label' => 'Quarterbacks'       },
  'runningbacks'   => { 'positions' => ['HB', 'FB'      ], 'label' => 'Running Backs'      },
  'receivers'      => { 'positions' => ['WR', 'TE'      ], 'label' => 'Receivers'          },
  'defensiveline'  => { 'positions' => ['NT', 'DT', 'DE'], 'label' => 'Defensive Linesmen' },
  'linebackers'    => { 'positions' => ['LB'            ], 'label' => 'Linebackers'        },
  'defensivebacks' => { 'positions' => ['CB', 'DB'      ], 'label' => 'Defensive Backs'    },
}


sr = StatRankings.new schools
sr.process_categories categories
