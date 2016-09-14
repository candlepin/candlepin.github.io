require 'rack/jekyll'
require 'rack/rewrite'
require 'rack/static'

use Rack::Static, :urls => ["/.well-known"]

use Rack::Rewrite do
  rewrite "/favicon.ico", "/images/favicon.ico"
  # The (?!.*?\.|.+/$) is a negative lookahead making sure that the last part
  # of the requested path does not have a period in it or end with a slash.
  # If there is a period, then the user is requesting a file.  If there is a
  # trailing slash, the user is requesting a directory.
  moved_permanently %r{(/.*/)((?!.+?\.|.+/$).+)}, '$1$2/'
end

# force_build will have Jekyll regenerate the site every time Rack is started.
# This means that we can simply restart the OpenShift app to force a refresh
# rather than require a redeployment.
run Rack::Jekyll.new(:auto => false, :force_build => true)
