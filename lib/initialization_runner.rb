require 'pathname'
require 'fileutils'
require 'optionparser'

# path to your application root.
APP_ROOT = Pathname.new File.expand_path('..', __dir__)

# Supress our default verbose logging unless we explicitly want to debug
ENV['RAILS_LOG_TO_STDOUT'] = ENV['DEBUG'] ? 'enabled' : 'false'

def parts
  @parts ||= {}
end

# Run a pre-defined or supplied block of code unless it's being skipped
def run_part(part)
  return if ARGV.include?("--skip-#{part}")

  parts[part]&.call
  yield if block_given?
end

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

def part(name, &block)
  parts[name] = block
end

def print_heading(heading)
  Rails.logger.debug "\n== #{heading} =="
end

#
# Define parts that are shared across scripts
#

part(:hooks) do
  print_heading 'Installing git hooks'
  system! 'git config core.hooksPath .githooks'
end

part(:bundle) do
  print_heading 'Installing dependencies'
  system! 'gem install bundler --conservative'
  system('bundle check') || system!('bundle install')
end

part(:clear) do
  print_heading 'Removing old logs and tempfiles'
  system! 'bin/rails log:clear tmp:clear'
end

part(:restart) do
  print_heading 'Restarting application server'
  system! 'bin/rails restart'
end

part(:verify) do
  print_heading 'Verifying setup'
  system! 'bin/rake RSPEC_PROFILES_DISABLED=true'
end
