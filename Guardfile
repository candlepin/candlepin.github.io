# More info at https://github.com/guard/guard#readme
# Courtesy http://dan.doezema.com/2014/01/setting-up-livereload-with-jekyll/

ignore %r{\.swp$}

ISOLATION_FILE = ".isolation_config.yml"
ENV['RACK_ENV'] = "development"

jekyll_config = ["_config.yml"]
if File.exists?(ISOLATION_FILE)
  UI.warning("Running with additional Jekyll configuration in #{ISOLATION_FILE}")
  jekyll_config << ISOLATION_FILE if File.exists?(ISOLATION_FILE)
end

guard 'jekyll-plus', :serve => true, :config => jekyll_config do
  watch %r{.*}

  # Guard's ignore ability is weird.  As far as I can tell, when you ignore
  # something, it is ignored globally and not just scoped to the particular
  # guard task.  Beware.
  ignore %r{^_site}
end

guard 'livereload' do
  watch %r{.*}
end
