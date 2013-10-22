require 'spec_helper'

class RevStateBaseTest < Test::Unit::TestCase
  def setup
    @var1 = true
  end

  def teardown
  end

  def test_hello_world
    assert_equal(true, @var1)
  end

end
