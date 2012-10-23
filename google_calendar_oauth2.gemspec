Gem::Specification.new do |s|
  s.name        = 'google_calendar_oauth2'
  s.version     = '0.1.0'
  s.summary     = "Work with Google Calendar using GData 3.0 + OAuth 2.0"
  s.description = "Work with Google Calendar using GData 3.0 + OAuth 2.0, adapted for ruby 1.8.7 + some features"
  s.authors     = ['Parker Young','Vitali Vasileuski']
  s.email       = ['parker.young@collegeplus.org', 'v5778844@gmail.com']
  s.homepage    = 'http://www.github.com/vasvitaly/google_calendar_oauth2.git'
  s.required_rubygems_version = '>= 1.3.6'
  s.files        = s.files = `git ls-files`.split("\n")
  s.require_path = 'lib'
  s.add_dependency 'google-api-client'
end