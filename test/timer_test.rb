require 'test_helper'

class TimerTest < Minitest::Test
  def test_basic_usage
    counterA = 0
    counterB = 0

    timer = Workers::Timer.new(0.01) do
      counterA += 1
    end

    while counterB < 100
      sleep 0.01
      break if counterA  >= 1
      counterB += 1
    end

    assert_equal(1, counterA)
  ensure
    timer.cancel
  end
end