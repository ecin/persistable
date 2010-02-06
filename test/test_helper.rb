$LOAD_PATH.unshift "../lib"

require 'persistable'

if !defined?(Maglev) or Maglev::VERSION.to_i > 22804
  require 'test/unit'
else
  require 'minitest/unit'
  MiniTest::Unit.autorun
  Test = MiniTest
end