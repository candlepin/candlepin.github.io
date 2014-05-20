# Use the OpenShift gem mirror
# See http://openshift.github.io/documentation/oo_cartridge_guide.html#ruby-mirror
source 'https://mirror.openshift.com/mirror/ruby/'
ruby '1.9.3'
gem 'git', "~> 1.2"
gem 'typogruby', "~> 1.0"
gem 'jekyll', "~> 2.0"
gem 'kramdown', "~> 1.3"
# Until https://github.com/adaoraul/rack-jekyll/pull/22 is accepted
gem 'rack-jekyll', :git => 'https://github.com/awood/rack-jekyll'
gem 'nokogiri', "~> 1.5.2"
gem 'stringex'
gem 'rack'
gem 'thin'

group :development do
  gem 'thor'
  gem 'safe_yaml'
  gem 'rack-livereload'
  gem 'guard-livereload'
  # Until https://github.com/imathis/guard-jekyll-plus/issues/25 is accepted
  gem 'guard-jekyll-plus', :git => 'https://github.com/awood/guard-jekyll-plus'
end
