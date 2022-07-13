require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

  contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter


# encapsulates code for clean up zipcodes, pull officials and create thank you letters #
def exercise_output(contents)
  contents.each do |row|
    id = row[0]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])
    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id,form_letter)
  end
end


  # something to pull the phone numbers from input file and normalize removing unwanted charaters #
  # also runs normalized numbers through check method and outs first name with number #
  # validate and correct numbers #
  def phone_numbers(contents)
    contents.each do |row|
      phone_number = row[:home_phone].tr('()-." "', '')
      puts "#{check_phone_number(phone_number)}: #{row[:first_name]}"
    end
  end

  def check_phone_number(phone_number)
    case 
    when phone_number.length < 10 || phone_number.length > 11
      print 'invaild number'
    when phone_number.length == 11 
      phone_number.start_with?('1') ? (print phone_number[1..-1]) : (print 'invalid number')
    else
      print phone_number
    end
  end

def registration_time(contents)
  time_array = []
  contents.each do |row|
    date_time = DateTime.strptime(row[:regdate], '%m/%d/%y %k')
    time_array << date_time.hour
  end

    hour_dist = Hash.new(0)
    time_array.each |hour|
      hour_dist[hour] += 1
  end
  puts hour_dist
end


