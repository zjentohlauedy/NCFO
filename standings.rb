#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'ProgRunner'

class Conference
  attr_reader :name, :schools

  class School
    attr_reader :name, :wins, :losses, :ties, :scored, :allowed

    def initialize( name, wins, losses, ties, scored, allowed )
      @name    = name
      @wins    = wins.to_i
      @losses  = losses.to_i
      @ties    = ties.to_i
      @scored  = scored.to_i
      @allowed = allowed.to_i
    end

    def <=>( other )
      i_values = get_comp_values
      o_values = other.get_comp_values

      i = 0
      while i < i_values.length  and (i_values[i] <=> o_values[i]) == 0
        i += 1
      end

      if i < i_values.length
        return i_values[i] <=> o_values[i]
      end

      return 0
    end

    def get_comp_values
      return [ @wins, 10 - @losses, @scored - @allowed, @scored, @allowed ]
    end

    def to_s
      return sprintf "%-15s %2d %2d %2d", @name, @wins, @losses, @ties
    end
  end

  def initialize( name, schools )
    @name = name
    @schools = schools
  end

  def load_schools( prog )
    schools = @schools
    @schools = Array.new

    schools.each do |school|
      prog.execute "#{school}.stat"

      if prog.success?
        ( name, wins, losses, ties, scored, allowed ) = prog.get_output.split /,/
      else
        ( name, wins, losses, ties, scored, allowed ) = [school, 0, 0, 0, 0, 0]
      end

      @schools.push School.new( name, wins, losses, ties, scored, allowed )
    end
  end

  def print_standings
    printf "%-16s W  L  T\n", @name
    print "-                -  -  -\n"

    @schools.each do |school|
      print "#{school.to_s}\n"
    end
  end

end


def print_standings( conferences )
  conferences.each do |conference|
    printf "%-16s W  L  T    ", conference.name
  end

  print "\n"

  conferences.each do |x|
    print "-                -  -  -    "
  end

  print "\n"

  num_teams = conferences[0].schools.length
  i = 0
  while i < num_teams
    conferences.each do |conference|
      printf "%s    ", conference.schools[i].to_s
    end

    print "\n"

    i += 1
  end
end


record_prog = ProgRunner.new location, "get_record"

conferences = [ Conference.new( 'New England', [ 'uct', 'ume', 'uma', 'unh', 'uri', 'uvt' ] ),
                Conference.new( 'Atlantic',    [ 'ude', 'umd', 'unj', 'uny', 'uva', 'uwv' ] ),
                Conference.new( 'Southeast',   [ 'ual', 'ufl', 'uga', 'unc', 'usc', 'utn' ] ),
                Conference.new( 'Great Lake',  [ 'uil', 'uin', 'uky', 'umi', 'uoh', 'upa' ] ),
                Conference.new( 'Southwest',   [ 'uaz', 'uca', 'uco', 'unv', 'unm', 'uut' ] ),
                Conference.new( 'Northwest',   [ 'uid', 'umt', 'une', 'uor', 'uwa', 'uwy' ] ),
                Conference.new( 'Midwest',     [ 'uia', 'uks', 'umn', 'und', 'usd', 'uwi' ] ),
                Conference.new( 'South',       [ 'uar', 'ula', 'ums', 'umo', 'uok', 'utx' ] ) ]

conferences.each do |conference|
  conference.load_schools record_prog
  conference.schools.sort!
  conference.schools.reverse!
end

print_standings conferences[0..3]

print "\n"
print "\n"

print_standings conferences[4..7]
