require 'rack/jekyll'

use Rack::Static,
  # Poor man's redirects
  :urls => {
    "/favicon.ico" => "/images/favicon.ico"
  }

run Rack::Jekyll.new(:no_render => true)
