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
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue => exception
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_numbers(phone_number)
  phone_number = phone_number.tr('^0-9', '')
  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11 && phone_number[0] == '1'
    phone_number[1..-1]
  else
    'The phone number you entered was not valid!'
  end
end

def get_reg_hour(reg_date)
  reg_time = reg_date.split[1]
  reg_time.split(':')[0]
end

def get_reg_day_of_week(reg_date)
  reg_date = reg_date.split[0].split('/')
  stuff = Date.new(reg_date[2].to_i, reg_date[0].to_i, reg_date[1].to_i)
  stuff.strftime('%A')
end

puts 'Event Manager Initialized'

