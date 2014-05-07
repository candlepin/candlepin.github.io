# More info at https://github.com/guard/guard#readme
# Courtesy http://dan.doezema.com/2014/01/setting-up-livereload-with-jekyll/

ignore %r{\.swp$}

guard 'jekyll-plus', :serve => true do
  watch %r{.*}
  ignore %r{^_site}
end

guard 'livereload' do
  watch %r{.*}
end
