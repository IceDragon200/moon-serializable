require 'codeclimate-test-reporter'
require 'simplecov'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'

CodeClimate::TestReporter.start
SimpleCov.start

require 'moon-serializable/load'
