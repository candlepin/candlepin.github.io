require 'rack/jekyll'
require 'rack/livereload'

use Rack::LiveReload, :min_delay => 500, :max_delay => 1000, :no_swf => true, :source => :vendored
run Rack::Jekyll.new
