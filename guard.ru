require 'rack/livereload'
require './_rack/isolation.rb'
use Rack::LiveReload,
  :min_delay => 500,
  :max_delay => 2000,
  :no_swf => true,
  :source => :vendored

use Rack::Static,
  # Poor man's redirects
  :urls => {
    "/favicon.ico" => "/images/favicon.ico"
  }

run Rack::IsolationInjector.new
