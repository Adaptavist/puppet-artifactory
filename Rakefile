require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

ENV['STRICT_VARIABLES']='no'
task :default => [:spec, :lint, :syntax]
