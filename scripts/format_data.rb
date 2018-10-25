#!/usr/bin/ruby

def usage
  puts  "Usage: " + $0 + " transitions_file rules_file"
end

# We must have exactly two file names
if not ARGV.length == 2
  usage
  exit
end

transitions_file = File.open(ARGV[0])
rules_file = File.open(ARGV[1])

slash_position = ARGV[1].rindex('/')
if slash_position == nil
  slash_position = 0
else
  slash_position += 1
end
new_file_name = ARGV[1].dup
new_file_name = new_file_name.insert slash_position, "new_"

new_rules_file = File.open( new_file_name, 'w' )

variables = Array.new
not_variables = Array.new
action_values = Array.new

transitions_file.each do |line|
  if line.start_with?('VAR ')
    words = line.split(' ')
    variables.push( words[1] )
  elsif line.start_with?('VAR* ')
    words = line.split(' ')
    not_variables.push( words[1] )

    if words[1].eql? "action"
      for i in (2...words.length)
        action_values.push( words[ i ] )
      end
    end
  end
end

total_variables_number = variables.length + not_variables.length

if total_variables_number <= 36 
  new_names = ("a".."z").to_a
elsif total_variables_number <= 1296
  new_names = ("aa".."zz").to_a
elsif total_variables_number <= 46656
  new_names = ("aaa".."zzz").to_a
elsif total_variables_number <= 1679616
  new_names = ("aaaa".."zzzz").to_a
else
  puts("Too many variables")
  exit
end

if action_values.length <= 10
  new_values = ('0'...'9').to_a
elsif action_values.length <= 100
  new_values = ('00'...'99').to_a
elsif action_values.length <= 1000
  new_values = ('000'...'999').to_a
elsif action_values.length <= 10000
  new_values = ('0000'...'9999').to_a
else
  puts("Too many actions")
  exit
end

# write the action variable name and its domain size on the first line
# new_rules_file.write( "#{new_names[total_variables_number-1]} #{action_values.length}\n" )

# For each rules
rules_file.each do |line|

  new_line = line

  for i in 0...variables.length
    if new_line.include? variables[i]
      new_line = new_line.gsub variables[i], new_names[i]
    end
  end

  for i in 0...not_variables.length
    if new_line.include? not_variables[i]
      new_line = new_line.gsub not_variables[i], new_names[i+variables.length]
    end
  end

  for i in 0...action_values.length
    if new_line.include? action_values[i]
      new_line = new_line.gsub action_values[i], new_values[i]
    end
  end

  new_line = new_line.gsub 'T,', ''
  new_line = new_line.gsub ',T-1', ''
  new_line = new_line.gsub ':-', ':'
  new_line = new_line.gsub ').', ')'
  new_line = new_line.gsub '(', '='
  new_line = new_line.gsub ')', ''

  if not new_line.include? ' : '
    new_line.insert -2, " : "
  end
  
  new_rules_file.write( new_line )

end

new_rules_file.close

exit
