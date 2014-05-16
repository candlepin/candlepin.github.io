# More info at https://github.com/guard/guard#readme
# Courtesy http://dan.doezema.com/2014/01/setting-up-livereload-with-jekyll/

# Heavy handed fix for annoying SafeYAML bug:
# https://github.com/dtao/safe_yaml/issues/10#issuecomment-13039602
notification :off
ignore %r{\.swp$}

ISOLATION_FILE = ".isolation_config.yml"

jekyll_config = ["_config.yml"]
if File.exists?(ISOLATION_FILE)
  UI.warning("Running with additional Jekyll configuration in #{ISOLATION_FILE}")
  jekyll_config << ISOLATION_FILE
end

class Guard::ReRack
  def initialize(jekyll_config)
    @jekyll_config = jekyll_config
    @reload = false
  end

  def call(guard_class, event, *args)
    event.to_s =~ /(.*)_(begin|end)/
    case $2
      when "begin"
        if @jekyll_config.map { |f| args.first.include?(f) }.any?
          @reload = true
        end
      when "end"
        if @reload
          ::Guard.guards(:rack).reload
          @reload = false
        end
      else
        UI.warn "I'm not equipped to handle #{event.to_s}!"
    end
  end
end

guard 'jekyll-plus', :extensions => ['less'], :config => jekyll_config do
  watch %r{.*}

  # Guard's ignore ability is weird.  As far as I can tell, when you ignore
  # something, it is ignored globally and not just scoped to the particular
  # guard task.  Beware.
  ignore %r{^_site}
  callback(ReRack.new(jekyll_config), [
    :run_on_modifications_begin,
    :run_on_additions_begin,
    :run_on_removals_begin,
    :run_on_modifications_end,
    :run_on_additions_end,
    :run_on_removals_end,
  ])
end

guard 'rack', :port => 4000, :force_run => true, :daemon => true do
  # If scoped ignores worked, we'd want the following line.
  # watch %r{^_site}
end

guard 'livereload', :grace_period => 4 do
  watch %r{.*}
end
