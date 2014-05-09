require 'rack/jekyll'

# For RACK_ENV, valid options are "development", "deployment", and "none"
# "development" is the default.
if ENV['RACK_ENV'] == "development"
  require 'rack/livereload'
  use Rack::LiveReload,
    :min_delay => 500,
    :max_delay => 2000,
    :no_swf => true,
    :source => :vendored
end

run Rack::Jekyll.new
