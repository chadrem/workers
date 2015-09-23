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
    test_thread = Thread.current

    worker.perform { sleep 0.2 }
    worker.perform { raise 'uh oh' }
    worker.perform { test_thread.wakeup }
    sleep

    assert(worker.alive?)
    assert_kind_of(RuntimeError, worker.exception)
  end
end
