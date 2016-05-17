# The odin project event_manager practice
# we parsed a csv file and then used the sunlight congress gem
# to obtain the corresponding legislators for each person based on the person's
# zipcode. We then created html letters using a script to make personalized
# thank you messages for each person.

# Practiced with writing and reading files, parsing csv files with the ruby
# CSV library, and also practiced using ERB (embedded ruby) with bindings.

# tutorial website: http://tutorials.jumpstartlab.com/projects/eventmanager.html

require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = 'e179a6973728c4dd3fb1204283aaccb5'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, name, form_letter)
  Dir.mkdir('output') unless Dir.exist? 'output'

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    puts "generating letter for #{id}: #{name}"
    file.puts form_letter
  end
end

puts 'EventManager initialized!'

contents = CSV.open 'event_attendees.csv', headers: true,
                                           header_converters: :symbol

template_letter = File.read 'form_letter.erb'
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id, name, form_letter)
end

puts 'All files generated succesfully!'
