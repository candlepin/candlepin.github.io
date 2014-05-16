require 'rack/jekyll'

# For RACK_ENV, valid options are "development", "deployment", and "none"
# "development" is the default.
if ENV['RACK_ENV'] == "development"
  require 'rack/livereload'
  require './_rack/isolation.rb'
  use Rack::LiveReload,
    :min_delay => 500,
    :max_delay => 2000,
    :no_swf => true,
    :source => :vendored
  use Rack::IsolationInjector
end

use Rack::Static,
  # Poor man's redirects
  :urls => {
    "/favicon.ico" => "/images/favicon.ico"
  }

run Rack::Jekyll.new
