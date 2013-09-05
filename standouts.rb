#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'ProgRunner'

class Stats
  include Comparable

  def initialize
    @direction = :descending
    @sort_key = nil
  end

  def <=>( other )
    if @direction == :ascending
      get_sort_key.to_f <=> other.get_sort_key.to_f
    else
      other.get_sort_key.to_f <=> get_sort_key.to_f
    end
  end

  def set_direction( direction )
    @direction = direction
  end

  def set_sort_key( key )
    @sort_key = key
  end

  def get_sort_key
    send @sort_key
  end

  def to_s
    sprintf "%s %-20s %-15s %4d", @pos, @name, @school, get_sort_key.to_i
  end

end

class Qbr < Stats
  attr_reader :yards, :td, :pct

  def initialize( data )
    super()
    ( @pos, @name, @school, @att, @comp, @pct, @yards, @avg, @td, @int ) = data.split /;/
  end

  def qbr
    pct = @comp.to_f / @att.to_f * 100.0
    qbr = @yards.to_f
    qbr += 2.0 * (@td.to_f ** 2.0) + 5.0 * @td.to_f + 1
    qbr -= 2.0 * (@int.to_f ** 2.0) + 5.0 * @int.to_f + 1
    qbr += (pct ** (pct / 100.0)) * 3.0 / 2.0
    return (qbr / 5)
  end

  def to_s
    sprintf "%s %-20s %-15s %7.2f", @pos, @name, @school, get_sort_key.to_f
  end

end

class Passing < Stats
  attr_reader :yards, :td, :pct

  def initialize( data )
    super()
    ( @pos, @name, @school, @att, @comp, @pct, @yards, @avg, @td, @int ) = data.split /;/
  end

end

class Rushing < Stats
  attr_reader :yards, :td

  def initialize( data )
    super()
    ( @pos, @name, @school, @att, @yards, @avg, @td ) = data.split /;/
  end

end

class Receiving < Stats
  attr_reader :yards, :td, :rec

  def initialize( data )
    super()
    ( @pos, @name, @school, @rec, @yards, @avg, @td ) = data.split /;/
  end

end

class AllPurpose < Stats
  attr_reader :yards, :td

  def initialize( data )
    super()
    ( @pos, @name, @school, @yards, @td ) = data.split /;/
  end

end

class Overall < Stats
  attr_reader :yards, :td

  def initialize( data )
    super()
    ( @pos, @name, @school, @yards, @td ) = data.split /;/
  end

end

class Tackles < Stats
  attr_reader :tackles

  def initialize( data )
    super()
    ( @pos, @name, @school, @tackles ) = data.split /;/
  end

end

class Sacks < Stats
  attr_reader :sacks

  def initialize( data )
    super()
    ( @pos, @name, @school, @sacks ) = data.split /;/
  end

end

class Interceptions < Stats
  attr_reader :int

  def initialize( data )
    super()
    ( @pos, @name, @school, @int ) = data.split /;/
  end

end


class StatRankings

  def initialize( stats_prog, schools, extension = "stat" )
    @stats_prog = stats_prog
    @schools    = schools
    @extension  = extension
    @players    = Array.new
  end

  def process_categories( categories )
    categories.each do |key, value|
      compile_stats value.fetch( 'class' ), value.fetch( 'type' )

      value.fetch( 'stats' ).each do |stat|
        print "#{stat.fetch 'label'}\n"
        print_top_players stat.fetch( 'stat' )
        print "\n"
      end
    end
  end

  def compile_stats( object, type )
    @players = Array.new

    @schools.each do |school|
      @stats_prog.execute "#{school}.#{@extension}", type

      if @stats_prog.success?
        @stats_prog.get_output.split( "\n" ).each do |line|
          @players.push( object.new line.chomp )
        end
      end
    end
  end

  def print_top_players( stat, count=15 )
    @players.each do |player|
      player.set_sort_key stat
    end

    @players.sort!

    i = 0

    while i < [count, @players.length].min
      print "#{@players[i].to_s}\n"
      i += 1
    end
  end

end


stats_prog = ProgRunner.new location, "get_stats_by_type"

schools = [ 'ual', 'uar', 'uaz', 'uca', 'uco', 'uct', 'ude', 'ufl',
            'uga', 'uid', 'uil', 'uin', 'uia', 'uks', 'uky', 'ula',
            'uma', 'umd', 'ume', 'umi', 'umn', 'umo', 'ums', 'umt',
            'unc', 'und', 'une', 'unh', 'unj', 'unm', 'unv', 'uny',
            'uoh', 'uok', 'uor', 'upa', 'uri', 'usc', 'usd', 'utn',
            'utx', 'uut', 'uva', 'uvt', 'uwa', 'uwi', 'uwv', 'uwy',
            'aab', 'aar' ]

categories = {
  'qb_rating'     => {  'class' => Qbr,                 'type' => "A",
    'stats'       => [{ 'label' => "Passer Rating",     'stat' => :qbr     }]},

  'passing'       => {  'class' => Passing,             'type' => "A",
    'stats'       => [{ 'label' => "Passing Yards",     'stat' => :yards   },
                      { 'label' => "Passing TD",        'stat' => :td      }]},

  'rushing'       => {  'class' => Rushing,             'type' => "B",
    'stats'       => [{ 'label' => "Rushing Yards",     'stat' => :yards   },
                      { 'label' => "Rushing TD",        'stat' => :td      }]},

  'receiving'     => {  'class' => Receiving,           'type' => "C",
    'stats'       => [{ 'label' => "Receptions",        'stat' => :rec     },
                      { 'label' => "Receiving Yards",   'stat' => :yards   },
                      { 'label' => "Receiving TD",      'stat' => :td      }]},

  'all-purpose'   => {  'class' => AllPurpose,          'type' => "G",
    'stats'       => [{ 'label' => "All Purpose Yards", 'stat' => :yards   },
                      { 'label' => "All Purpose TD",    'stat' => :td      }]},

  'overall'       => {  'class' => Overall,             'type' => "H",
    'stats'       => [{ 'label' => "Overall Yards",     'stat' => :yards   },
                      { 'label' => "Overall TD",        'stat' => :td      }]},

  'tackling'      => {  'class' => Tackles,             'type' => "D",
    'stats'       => [{ 'label' => "Tackles",           'stat' => :tackles }]},

  'sacks'         => {  'class' => Sacks,               'type' => "E",
    'stats'       => [{ 'label' => "Sacks",             'stat' => :sacks   }]},

  'interceptions' => {  'class' => Interceptions,       'type' => "F",
    'stats'       => [{ 'label' => "Interceptions",     'stat' => :int     }]}
}

if ARGV.length == 1
  sr = StatRankings.new stats_prog, schools, ARGV[0]
else
  sr = StatRankings.new stats_prog, schools
end

sr.process_categories categories
