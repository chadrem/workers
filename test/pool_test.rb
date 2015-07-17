require 'test_helper'

class PoolTest < Minitest::Test
  def test_basic_usage
    pool = Workers::Pool.new
    successes = []

    pool.size.times do
      pool.perform { successes << true }
    end

    assert(pool.dispose(5))
    assert(Array.new(pool.size, true), successes)
  end

  def test_exception_during_perform
    pool = Workers::Pool.new
    success = false

    pool.size.times { pool.perform { raise 'uh oh' }}
    pool.perform { success = true }
    pool.dispose

    assert(success)
  end
end