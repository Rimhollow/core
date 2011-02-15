require 'machinist/data_mapper'
require 'sham'

#Before { Sham.reset }

Sham.define do
  email { Faker::Internet.free_email }
  boolean(:unique => false) { rand(2) == 0 }
  cap_id { Faker::Company.name.gsub /[^A-Z]/, '' }
  user_id { Faker::Internet.user_name.gsub '.', '' }

  description {
    place = String.new
    place += Faker::Address.city_prefix + ' ' if rand(2) == 0
    place += Faker::Address.state

    if rand(2) == 0
      "University of #{place}"
    else
      "#{place} University"
    end
  }


  address {
<<ADDY
#{Faker::Address.street_address(true)}
#{Faker::Address.city}, #{Faker::Address.state_abbr}
#{Faker::Address.zip_code}
ADDY
  }

end

Account.blueprint do
  id { Sham.cap_id }
  description
  report_email { Sham.email }
end

Project.blueprint do
  id { Sham.cap_id }
  description
end

User.blueprint do
  id { Sham.user_id }
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  email
  phone { Faker::PhoneNumber.phone_number }
  address
  is_admin_contact { Sham.boolean }
  is_tech_contact { Sham.boolean }
  account_id { 'OPERATIONS' }
end
