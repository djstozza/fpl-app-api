if ARGV.grep(/spec\.rb/).empty?
  require 'simplecov'

  changed_files = `
    git diff master... 2> /dev/null --name-only &&
    git diff --name-only --cached &&
    git ls-files --others --exclude-standard --modified
  `.split

  SimpleCov.start 'rails' do
    add_group('Branch', changed_files)

    # Use regexes to match start of project path

    add_filter %r{^/vendor/}
    add_filter %r{^/lib/}

    minimum_coverage 100
  end
end
