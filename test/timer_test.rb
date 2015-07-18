require 'test_helper'

class TimerTest < Minitest::Test
  def test_basic_usage_with_default_scheduler
    perform_basic_test(Workers.scheduler)
  end

  def test_basic_usage_with_bucket_scheduler
    scheduler = Workers::BucketScheduler.new
    perform_basic_test(scheduler)
  ensure
    scheduler.dispose
  end

  private

  def perform_basic_test(scheduler)
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