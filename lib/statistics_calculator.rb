class StatisticsCalculator
  def initialize(latencies)
    @latencies = latencies.sort
  end

  def min
    @latencies.min
  end

  def max
    @latencies.max
  end

  def avg
    @latencies.sum / @latencies.size
  end

  def stddev
    mean = avg
    Math.sqrt(@latencies.map { |lat| (lat - mean)**2 }.sum / @latencies.size)
  end

  def p90
    percentile(90)
  end

  def p99
    percentile(99)
  end

  private

  def percentile(p)
    @latencies[(p / 100.0 * (@latencies.size - 1)).round]
  end
end
