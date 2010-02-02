$LOAD_PATH.unshift "#{__FILE__}/../../lib"

require 'persistable'

if Maglev::VERSION.to_i > 22804
  require 'test/unit'
else
  require 'minitest/unit'
  MiniTest::Unit.autorun
  Test = MiniTest
end