require 'test_helper'

class WorkerTest < Minitest::Test
  def test_basic_usage
    worker = Workers::Worker.new
    success = false

    worker.perform { success = true }

    assert(worker.dispose(5))
    assert(success)
    assert_equal(false, worker.alive?)
  end

  def test_exception_during_perform
    worker = Workers::Worker.new

    worker.perform { raise 'uh oh' }

    assert_raises do
      worker.join(2)
    end
  end
end