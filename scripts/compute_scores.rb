#!/usr/bin/ruby

def usage
  puts  "Usage: " + $0 + " formatted_file"
end

def median( array )
  sorted = array.sort
  len = sorted.length
  (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
end

def normalize( array )
  min,max = array.minmax
  mean = ( max - min ).to_f / 2
  shift = max.to_f - mean
  array.map! {|x| ( x.to_f - shift ) / mean }
end

# We must have exactly two file names
if not ARGV.length == 1
  usage
  exit
end

file = File.open(ARGV[0])

slash_position = ARGV[0].rindex('/')
if slash_position == nil
  slash_position = 0
else
  slash_position += 1
end
new_file_name = ARGV[0].dup
new_file_name = new_file_name.insert slash_position, "scores_"

new_rules_file = File.open( new_file_name, 'w' )

total_executions = 0
ratios = Array.new
probabilities = Array.new
body_size = Array.new

score_size = Array.new
score_expressivity = Array.new

# For each rules
file.each do |line|

  words = line.split(' : ')
  head = words[0]
  body = words[1]
  
  if not head == nil
    values = head.split(',')
    exec = values[1].to_i
    match = values[2].to_i
    
    total_executions += exec
    ratios.push( exec.to_f / match.to_f )
    probabilities.push( exec )
  end

  if not body == nil
    body_size.push( body.split(', ').length )
  else
    body_size.push( 0 )
  end

end

total_rules = ratios.length

for i in (0...total_rules)
  probabilities[i] = probabilities[i].to_f / total_executions.to_f
end

ratio_expectation = ratios.inject(:+).to_f / ratios.size
median_size = median( body_size )

for i in (0...total_rules)
  score_size.push( median_size - body_size[i] )
  score_expressivity.push( probabilities[i] * ( ratios[i] - ratio_expectation ) )
end

normalize( score_size )
normalize( score_expressivity )

for i in (0...total_rules)
  score = score_size[i] + score_expressivity[i]
  new_rules_file.write( "#{score.round(4)}\n" )
end

#TODO: check soundness

new_rules_file.close

exit
