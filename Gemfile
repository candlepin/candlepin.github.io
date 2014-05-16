# Use the OpenShift gem mirror
# See http://openshift.github.io/documentation/oo_cartridge_guide.html#ruby-mirror
source 'https://mirror.openshift.com/mirror/ruby/'
ruby '1.9.3'
gem 'git', "~> 1.2"
gem 'typogruby', "~> 1.0"
gem 'jekyll', "~> 1.4"
gem 'kramdown', "~> 1.3"
gem 'rack-jekyll', "~> 0.4"
gem 'nokogiri', "~> 1.5.2"
gem 'stringex'
gem 'rack'
gem 'thin'

group :development do
  gem 'thor'
  gem 'safe_yaml'
  gem 'rack-livereload'
  gem 'guard-livereload'
  # Until https://github.com/imathis/guard-jekyll-plus/issues/24 gets fixed...
  gem 'guard-jekyll-plus', :git => 'https://github.com/awood/guard-jekyll-plus'
  gem 'guard-rack'
end
