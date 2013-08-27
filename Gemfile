source "http://rubygems.org"

gem 'data_mapper', ">= 1.2.0"
gem 'dm-is-list'
# Later versions of Haml are not backwards-compatible, and don't include Sass, so I'm explicitly
# specifying 3.1.8. --Robert Holland, 5/2/2013
gem 'haml', "<= 3.1.8"
gem 'libxml-ruby', "1.1.3"
gem 'nokogiri'
gem 'rake'
gem 'semver'
gem 'sinatra'
gem 'rack-ssl-enforcer'
gem 'thor'
gem 'uuid'
gem 'rjb'
gem 'curb', '0.7.15'
gem 'dm-postgres-adapter'
# if `hostname`.chomp != 'marsala.fcla.edu' 
#   gem 'dm-mysql-adapter'
# end
gem 'selenium-client'
gem "datyl", :git => "git://github.com/daitss/datyl.git"
gem "log4r"

# Added to avoid Ruby errors when starting the service. --Robert Holland, 4/19/2013
gem 'thin'

# this gem is WONK
case `uname`.chomp

when 'Darwin'
  gem 'sys-proctable', :path => '/Library/Ruby/Gems/1.8/gems/sys-proctable-0.9.1-universal-darwin'

else
  gem 'sys-proctable'
end

group :test do
  gem "cucumber", "1.1.0"
  gem "rack-test"
  gem "rspec"
  gem "fuubar"
  gem "webrat"
  gem 'ruby-debug'
  gem 'ruby-prof'
end

gemspec
