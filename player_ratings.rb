#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"


probabilities = [ { 'rating' => 5.0, 'value' =>    1, 'count' => 0 },
                  { 'rating' => 4.9, 'value' =>    3, 'count' => 0 },
                  { 'rating' => 4.8, 'value' =>    5, 'count' => 0 },
                  { 'rating' => 4.7, 'value' =>    6, 'count' => 0 },
                  { 'rating' => 4.6, 'value' =>    7, 'count' => 0 },
                  { 'rating' => 4.5, 'value' =>    9, 'count' => 0 },
                  { 'rating' => 4.4, 'value' =>   10, 'count' => 0 },
                  { 'rating' => 4.3, 'value' =>   11, 'count' => 0 },
                  { 'rating' => 4.2, 'value' =>   12, 'count' => 0 },
                  { 'rating' => 4.1, 'value' =>   13, 'count' => 0 },
                  { 'rating' => 4.0, 'value' =>   14, 'count' => 0 },
                  { 'rating' => 3.9, 'value' =>   15, 'count' => 0 },
                  { 'rating' => 3.8, 'value' =>   19, 'count' => 0 },
                  { 'rating' => 3.7, 'value' =>   24, 'count' => 0 },
                  { 'rating' => 3.6, 'value' =>   29, 'count' => 0 },
                  { 'rating' => 3.5, 'value' =>   33, 'count' => 0 },
                  { 'rating' => 3.4, 'value' =>   50, 'count' => 0 },
                  { 'rating' => 3.3, 'value' =>   75, 'count' => 0 },
                  { 'rating' => 3.2, 'value' =>  100, 'count' => 0 },
                  { 'rating' => 3.1, 'value' =>  125, 'count' => 0 },
                  { 'rating' => 3.0, 'value' =>  150, 'count' => 0 },
                  { 'rating' => 2.9, 'value' =>  200, 'count' => 0 },
                  { 'rating' => 2.8, 'value' =>  300, 'count' => 0 },
                  { 'rating' => 2.7, 'value' =>  400, 'count' => 0 },
                  { 'rating' => 2.6, 'value' =>  500, 'count' => 0 },
                  { 'rating' => 2.5, 'value' =>  600, 'count' => 0 },
                  { 'rating' => 2.4, 'value' =>  850, 'count' => 0 },
                  { 'rating' => 2.3, 'value' => 1000, 'count' => 0 },
                  { 'rating' => 2.2, 'value' =>  950, 'count' => 0 },
                  { 'rating' => 2.1, 'value' =>  700, 'count' => 0 },
                  { 'rating' => 2.0, 'value' =>  500, 'count' => 0 },
                  { 'rating' => 1.9, 'value' =>  300, 'count' => 0 },
                  { 'rating' => 1.8, 'value' =>  250, 'count' => 0 },
                  { 'rating' => 1.7, 'value' =>  200, 'count' => 0 },
                  { 'rating' => 1.6, 'value' =>  150, 'count' => 0 },
                  { 'rating' => 1.5, 'value' =>  100, 'count' => 0 },
                  { 'rating' => 1.4, 'value' =>   80, 'count' => 0 },
                  { 'rating' => 1.3, 'value' =>   65, 'count' => 0 },
                  { 'rating' => 1.2, 'value' =>   50, 'count' => 0 },
                  { 'rating' => 1.1, 'value' =>   35, 'count' => 0 },
                  { 'rating' => 1.0, 'value' =>   20, 'count' => 0 } ]


generator = Random.new Time.new.usec

total = 0

probabilities.each do |entry|
  total += entry.fetch 'value'
end

puts total

i = 0
while i < 2160
  roll = generator.rand total + 1

  probabilities.each do |entry|
    if (roll -= entry.fetch 'value') <= 0
      entry.store 'count', (entry.fetch( 'count' ) + 1)
      break;
    end
  end

  i += 1
end

probabilities.each do |entry|
  printf "%3.1f: %d\n", entry.fetch( 'rating' ), entry.fetch( 'count' )
end



#       5.0   10
# 4.5 - 4.9   30
# 4.0 - 4.4   60
# 3.5 - 3.9  120
# 3.0 - 3.4  500
# 2.5 - 2.9 2000
# 2.0 - 2.4 4000
# 1.5 - 1.9 1000
# 1.0 - 1.4  250

# 5.0    1
# 4.9    3
# 4.8    5
# 4.7    6
# 4.6    7
# 4.5    9
# 4.4   10
# 4.3   11
# 4.2   12
# 4.1   13
# 4.0   14
# 3.9   15
# 3.8   19
# 3.7   24
# 3.6   29
# 3.5   33
# 3.4   50
# 3.3   75
# 3.2  100
# 3.1  125
# 3.0  150
# 2.9  200
# 2.8  300
# 2.7  400
# 2.6  500
# 2.5  600
# 2.4  850
# 2.3 1000 <-
# 2.2  950
# 2.1  700
# 2.0  500
# 1.9  300
# 1.8  250
# 1.7  200
# 1.6  150
# 1.5  100
# 1.4   80
# 1.3   65
# 1.2   50
# 1.1   35
# 1.0   20




# 5.0   10
# 4.9    6
# 4.8    6
# 4.7    6
# 4.6    6
# 4.5    6
# 4.4   12
# 4.3   12
# 4.2   12
# 4.1   12
# 4.0   12
# 3.9   24
# 3.8   24
# 3.7   24
# 3.6   24
# 3.5   24
# 3.4  100
# 3.3  100
# 3.2  100
# 3.1  100
# 3.0  100
# 2.9  400
# 2.8  400
# 2.7  400
# 2.6  400
# 2.5  400
# 2.4  800
# 2.3  800 <-
# 2.2  800
# 2.1  800
# 2.0  800
# 1.9  200
# 1.8  200
# 1.7  200
# 1.6  200
# 1.5  200
# 1.4   50
# 1.3   50
# 1.2   50
# 1.1   50
# 1.0   50






#       5.0   1
# 4.5 - 4.9   3
# 4.0 - 4.4   6
# 3.5 - 3.9  12
# 3.0 - 3.4  50
# 2.5 - 2.9 200
# 2.0 - 2.4 400
# 1.5 - 1.9 100
# 1.0 - 1.4  25



#       5.0 39
# 4.5 - 4.9 266
# 4.0 - 4.4 270
# 3.5 - 3.9 264
# 3.0 - 3.4 268
# 2.5 - 2.9 278
# 2.0 - 2.4 249
# 1.5 - 1.9 265
# 1.0 - 1.4 261
