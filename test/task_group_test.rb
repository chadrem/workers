require 'test_helper'

class TaskGroupTest < Minitest::Test
  def test_basic_usage
    group = Workers::TaskGroup.new

    10.times do |i|
      10.times do |j|
        group.add do
          group.synchronize do
            i * j
          end
        end
      end
    end

    group.run

    assert_equal(100, group.successes.length)
    assert_equal([], group.failures)
  end

  def test_failure
    group = Workers::TaskGroup.new

    10.times do |i|
      10.times do |j|
        group.add do
          raies 'uh oh'
        end
      end
    end

    group.run

    assert_equal(100, group.failures.length)
    assert_equal([], group.successes)
  end
end