require 'rack/jekyll'
require 'rack/rewrite'

use Rack::Rewrite do
  rewrite "/favicon.ico", "/images/favicon.ico"
  # The (?!.*?\.|.+/$) is a negative lookahead making sure that the last part
  # of the requested path does not have a period in it or end with a slash.
  # If there is a period, then the user is requesting a file.  If there is a
  # trailing slash, the user is requesting a directory.
  moved_permanently %r{(/.*/)((?!.+?\.|.+/$).+)}, '$1$2/'
end

run Rack::Jekyll.new(:auto => true)
