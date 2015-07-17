require 'test_helper'

class PeriodicTimerTest < Minitest::Test
  def test_basic_usage
    counterA = 0
    counterB = 0

    timer = Workers::PeriodicTimer.new(0.01) do
      counterA += 1
    end

    while counterB < 100
      sleep 0.01
      break if counterA >= 5
      counterB += 1
    end

    assert(counterA >= 5)
  ensure
    timer.cancel
  end
end