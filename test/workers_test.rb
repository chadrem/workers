require 'test_helper'

class WorkersTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Workers::VERSION
  end

  def test_parallel_map
    result = Workers.map([1, 2, 3, 4, 5], :max_tries => 100) do |i|
      if rand <= 0.5
        raise 'sad face'
      end

      i * i
    end

    assert_equal([1, 4, 9, 16, 25], result)
  end
end
