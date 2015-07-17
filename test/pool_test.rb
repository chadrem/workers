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

    (pool.size * 3).times { pool.perform { raise 'uh oh' }}
    pool.perform { success = true }

    pool.dispose

    assert(success)
  end

  def test_contracting
    pool = Workers::Pool.new
    orig_size = pool.size

    pool.contract(orig_size / 2)

    assert_equal(orig_size / 2, pool.size)
  ensure
    pool.dispose
  end

  def test_expanding
    pool = Workers::Pool.new
    orig_size = pool.size

    pool.expand(orig_size * 2)

    assert_equal(orig_size * 3, pool.size)
  ensure
    pool.dispose
  end

  def test_resizing
    pool = Workers::Pool.new
    orig_size = pool.size

    pool.resize(orig_size * 2)

    assert_equal(orig_size * 2, pool.size)

    pool.resize(orig_size / 2)

    assert_equal(orig_size / 2, pool.size)
  ensure
    pool.dispose
  end
end