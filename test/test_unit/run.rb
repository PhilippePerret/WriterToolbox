# encoding: UTF-8
require 'test/unit'

ONLINE        = false
OFFLINE       = true
ONLY_REQUIRE  = true
require './lib/required'

Dir["./test/test_unit/**/*_spec.rb"].each do |p|
  require p
end
