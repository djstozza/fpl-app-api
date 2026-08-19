if ARGV.grep(/spec\.rb/).empty?
  require 'simplecov'

  changed_files = `
    git diff master... 2> /dev/null --name-only &&
    git diff --name-only --cached &&
    git ls-files --others --exclude-standard --modified
  `.split

  SimpleCov.start 'rails' do
    group('Branch', changed_files)

    skip %r{\Avendor/}
    skip %r{\Alib/}

    minimum_coverage 100
  end
end
