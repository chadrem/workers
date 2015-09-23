require 'test_helper'

class TaskTest < Minitest::Test
  def test_basic_usage
    counter = 0
    perform_success = false
    finished_success = false

    task = Workers::Task.new(
      :input => [1, 2, 3],
      :on_perform => proc { |input|
        counter += 1
        raise 'uh oh' if counter < 3
        perform_success = true
        input.map { |i| i**2 }
      },
      :on_finished => proc { |t|
        finished_success = true
        assert_equal(task, t)
      },
      :max_tries => 10
    )

    task.run

    assert(perform_success)
    assert(finished_success)
    assert_equal([1, 4, 9], task.result)
    assert_equal(3, task.tries)
  end

  def test_failure
    finished_success = false

    task = Workers::Task.new(
      :on_perform => proc {
        raise 'uh oh'
      },
      :on_finished => proc {
        finished_success = true
      },
      :max_tries => 10
    )

    task.run

    assert(finished_success)
    assert_equal(10, task.tries)
    assert_kind_of(RuntimeError, task.exception)
  end
end
