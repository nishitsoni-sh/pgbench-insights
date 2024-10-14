require 'csv'
require 'descriptive_statistics'
require 'fileutils'
require 'time' # Needed for time calculations

# Helper method to calculate metrics
def calculate_metrics(latencies)
  {
    lowest: latencies.min,
    highest: latencies.max,
    mean: latencies.mean,
    stddev: latencies.standard_deviation,
    percentile_90: latencies.percentile(90)
  }
end

# Process files and extract latencies and timestamps
def process_files(file_pattern)
  latencies = []
  rows = []
  timestamps = []
  Dir.glob(file_pattern).each do |file|
    CSV.foreach(file) do |row|
      timestamps << Time.parse(row[1]) # Assuming the timestamp is in the 2nd column (index 1)
      latencies << row[2].to_f # Assuming the latency is in the 3rd column (index 2)
      rows << row # Keep all the original data intact
    end
  end
  [latencies, timestamps, rows]
end

# Write all data from original files to a single output file (including latency and other columns)
def write_to_file(filename, rows)
  CSV.open(filename, "w") do |csv|
    rows.each { |row| csv << row }
  end
end

# Append the metrics and time range to a file
def append_metrics_to_file(output_file, metrics, start_time, end_time, total_span_hours)
  File.open(output_file, "a") do |file| # Open the file in append mode ("a")
    file.puts "\n=== New Metrics ==="
    file.puts "Metrics: #{metrics}"
    file.puts "Start Time: #{start_time}"
    file.puts "End Time: #{end_time}"
    file.puts "Total Span (hours): #{total_span_hours}"
  end
end

# Main execution
def main
  if ARGV.length != 2
    puts "Usage: ruby latency_processor.rb <input_folder> <output_folder>"
    exit
  end

  input_folder = ARGV[0]
  output_folder = ARGV[1]

  # Ensure the output folder exists
  FileUtils.mkdir_p(output_folder)

  # Crunchy and Heroku file patterns
  crunchy_pattern = File.join(input_folder, "crunchy_latencies_*.csv")
  heroku_pattern = File.join(input_folder, "heroku_latencies_*.csv")

  # Process latencies and timestamps
  crunchy_latencies, crunchy_timestamps, crunchy_rows = process_files(crunchy_pattern)
  heroku_latencies, heroku_timestamps, heroku_rows = process_files(heroku_pattern)

  # Write all original data to separate files in the output folder
  write_to_file(File.join(output_folder, 'all_crunchy_latencies.csv'), crunchy_rows)
  write_to_file(File.join(output_folder, 'all_heroku_latencies.csv'), heroku_rows)

  # Calculate metrics
  crunchy_metrics = calculate_metrics(crunchy_latencies)
  heroku_metrics = calculate_metrics(heroku_latencies)

  # Get the start and end time for both sets
  crunchy_start_time = crunchy_timestamps.first
  crunchy_end_time = crunchy_timestamps.last
  heroku_start_time = heroku_timestamps.first
  heroku_end_time = heroku_timestamps.last

  # Calculate the total span in hours for both Crunchy and Heroku
  crunchy_total_span_hours = ((crunchy_end_time - crunchy_start_time) / 3600.0).round(2)
  heroku_total_span_hours = ((heroku_end_time - heroku_start_time) / 3600.0).round(2)

  # Append the metrics and times to files in the output folder
  append_metrics_to_file(File.join(output_folder, 'crunchy_metrics.txt'), crunchy_metrics, crunchy_start_time, crunchy_end_time, crunchy_total_span_hours)
  append_metrics_to_file(File.join(output_folder, 'heroku_metrics.txt'), heroku_metrics, heroku_start_time, heroku_end_time, heroku_total_span_hours)

  puts "Latencies and metrics have been appended to #{output_folder}"
end

main
