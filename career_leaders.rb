#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'ProgRunner'

class Stats
  include Comparable

  attr_accessor :when

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
    sprintf "%s %s %-20s %-15s %5d", @when, @pos, @name, @school, get_sort_key.to_i
  end

end

class Qbr < Stats
  attr_reader :name, :games, :att, :comp, :yards, :td, :int, :pct

  def initialize( data )
    super()
    ( @pos, @name, @school, @att, @comp, pct, @yards, avg, @td, @int ) = data.split /;/

    @att   = @att.to_i
    @comp  = @comp.to_i
    @yards = @yards.to_i
    @td    = @td.to_i
    @int   = @int.to_i

    if @att > 0
      @games = 1
    else
      @games = 0
    end
  end

  def qbr
    comp  = @comp.to_f / @games.to_f
    att   = @att.to_f / @games.to_f
    yards = @yards.to_f / @games.to_f
    td    = @td.to_f / @games.to_f
    int   = @int.to_f / @games.to_f

    pct = comp.to_f / att.to_f * 100.0
    qbr = yards.to_f
    qbr += 2.0 * (td.to_f ** 2.0) + 5.0 * td.to_f + 1
    qbr -= 2.0 * (int.to_f ** 2.0) + 5.0 * int.to_f + 1
    qbr += (pct ** (pct / 100.0)) * 3.0 / 2.0
    return (qbr / 5)
  end

  def add( other )
    @games += other.games
    @att   += other.att
    @comp  += other.comp
    @yards += other.yards
    @td    += other.td
    @int   += other.int
  end

  def to_s
    sprintf "%s %s %-20s %-15s %8.2f", @when, @pos, @name, @school, get_sort_key.to_f
  end

end

class Passing < Stats
  attr_reader :name, :att, :comp, :yards, :td, :int, :pct

  def initialize( data )
    super()
    ( @pos, @name, @school, @att, @comp, pct, @yards, avg, @td, @int ) = data.split /;/

    @att   = @att.to_i
    @comp  = @comp.to_i
    @yards = @yards.to_i
    @td    = @td.to_i
    @int   = @int.to_i
  end

  def add( other )
    @att   += other.att
    @comp  += other.comp
    @yards += other.yards
    @td    += other.td
    @int   += other.int
  end

end

class Rushing < Stats
  attr_reader :name, :att, :yards, :td

  def initialize( data )
    super()
    ( @pos, @name, @school, @att, @yards, avg, @td ) = data.split /;/

    @att   = @att.to_i
    @yards = @yards.to_i
    @td    = @td.to_i
  end

  def add( other )
    @att   += other.att
    @yards += other.yards
    @td    += other.td
  end

end

class Receiving < Stats
  attr_reader :name, :rec, :yards, :td, :rec

  def initialize( data )
    super()
    ( @pos, @name, @school, @rec, @yards, avg, @td ) = data.split /;/

    @rec   = @rec.to_i
    @yards = @yards.to_i
    @td    = @td.to_i
  end

  def add( other )
    @rec   += other.rec
    @yards += other.yards
    @td    += other.td
  end

end

class AllPurpose < Stats
  attr_reader :name, :yards, :td

  def initialize( data )
    super()
    ( @pos, @name, @school, @yards, @td ) = data.split /;/

    @yards = @yards.to_i
    @td    = @td.to_i
  end

  def add( other )
    @yards += other.yards
    @td    += other.td
  end

end

class Overall < Stats
  attr_reader :name, :yards, :td

  def initialize( data )
    super()
    ( @pos, @name, @school, @yards, @td ) = data.split /;/

    @yards = @yards.to_i
    @td    = @td.to_i
  end

  def add( other )
    @yards += other.yards
    @td    += other.td
  end

end

class Tackles < Stats
  attr_reader :name, :tackles

  def initialize( data )
    super()
    ( @pos, @name, @school, @tackles ) = data.split /;/

    @tackles = @tackles.to_i
  end

  def add( other )
    @tackles += other.tackles
  end

end

class Sacks < Stats
  attr_reader :name, :sacks

  def initialize( data )
    super()
    ( @pos, @name, @school, @sacks ) = data.split /;/

    @sacks = @sacks.to_i
  end

  def add( other )
    @sacks += other.sacks
  end

end

class Interceptions < Stats
  attr_reader :name, :int

  def initialize( data )
    super()
    ( @pos, @name, @school, @int ) = data.split /;/

    @int = @int.to_i
  end

  def add( other )
    @int += other.int
  end

end


class StatRankings
  attr_accessor :extension, :when

  def initialize( stats_prog, schools, extension = "stat" )
    @stats_prog = stats_prog
    @schools    = schools
    @extension  = extension
    @when       = "Unknown"
  end

  def process_categories( categories )
    categories.each do |key, value|
      players = value.fetch 'players', nil

      if players.nil?
        players = Array.new
      end

      compile_stats players, value.fetch( 'class' ), value.fetch( 'type' )

      value.store 'players', players
    end
  end

  def compile_stats( players, object, type )
    @schools.each do |school|
      @stats_prog.execute "#{school}.#{@extension}", type

      if @stats_prog.success?
        @stats_prog.get_output.split( "\n" ).each do |line|
          player = object.new line.chomp

          p = find_player players, player

          if p.nil?
            players.push( player )
          else
            p.add player
          end
        end
      end
    end
  end

  def find_player( players, player )
    players.each do |p|
      if p.name ==  player.name
        return p
      end
    end

    return nil
  end

  def generate_report( categories )
    categories.each do |key, value|
      value.fetch( 'stats' ).each do |stat|
        print "#{stat.fetch 'label'}\n"
        print_top_players value.fetch( 'players' ), stat.fetch( 'stat' ), 25
        print "\n"
      end
    end
  end

  def print_top_players( players, stat, count=15 )
    players.each do |player|
      player.set_sort_key stat
    end

    players.sort!

    i = 0

    while i < [count, players.length].min
      print "#{players[i].to_s}\n"
      i += 1
    end
  end

end


stats_prog = ProgRunner.new "../../#{location}", "get_stats_by_type"

schools = [ 'ual', 'uar', 'uaz', 'uca', 'uco', 'uct', 'ude', 'ufl',
            'uga', 'uid', 'uil', 'uin', 'uia', 'uks', 'uky', 'ula',
            'uma', 'umd', 'ume', 'umi', 'umn', 'umo', 'ums', 'umt',
            'unc', 'und', 'une', 'unh', 'unj', 'unm', 'unv', 'uny',
            'uoh', 'uok', 'uor', 'upa', 'uri', 'usc', 'usd', 'utn',
            'utx', 'uut', 'uva', 'uvt', 'uwa', 'uwi', 'uwv', 'uwy' ]

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

sr = StatRankings.new stats_prog, schools

print "Processing..."
Dir.glob("S[0-9][0-9]").each do |season|
  Dir.chdir(season) do
    Dir.glob("W[0-9][0-9]").each do |week|
      Dir.chdir(week) do
        next if ["W00", "W11", "W12", "W13"].include? week

        print "."
        sr.when = "#{season}:#{week}"

        if week == "W01"
          sr.extension = "stat"
        else
          sr.extension = "statx"
        end

        sr.process_categories categories
      end
    end
  end
end
print ":)\n"

sr.generate_report categories
