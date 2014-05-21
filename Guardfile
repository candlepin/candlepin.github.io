# More info at https://github.com/guard/guard#readme
# Courtesy http://dan.doezema.com/2014/01/setting-up-livereload-with-jekyll/

ignore %r{\.swp$}

ISOLATION_FILE = ".isolation_config.yml"

jekyll_config = ["_config.yml"]
if File.exist?(ISOLATION_FILE)
  UI.warning("Running with additional Jekyll configuration in #{ISOLATION_FILE}")
  jekyll_config << ISOLATION_FILE
end

guard 'jekyll-plus',
  :extensions => ['less'],
  :config => jekyll_config,
  :serve => true,
  :rack_config => 'guard.ru' do

  watch %r{.*}

  # Guard's ignore ability is weird.  As far as I can tell, when you ignore
  # something, it is ignored globally and not just scoped to the particular
  # guard task.  Beware.
  ignore %r{^_site}
end

guard 'livereload', :grace_period => 4 do
  watch %r{.*}
end
