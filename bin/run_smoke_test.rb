# bin/main.rb
require_relative '../lib/environment_loader'
require_relative '../lib/seeding_processor'
require_relative '../lib/pgbench_runner'
require_relative '../lib/log_processor'
require 'fileutils'
require 'time'

def main
  # Load environment variables from the config file
  config_file = ARGV[0]
  EnvironmentLoader.load_env(config_file)

  # Validate parameters from the environment
  clients = ENV['CLIENTS']
  duration = ENV['DURATION']
  log_dir = ENV['LOG_DIR']
  app_dir = ENV['APP_DIR']

  if clients.nil? || duration.nil? || log_dir.nil? || clients.to_i <= 0 || duration.to_i <= 0
    puts "Configuration error: Please provide valid number_of_clients, duration_in_seconds, and log_directory in the config file."
    exit 1
  end

  puts app_dir
  csv_file = "#{app_dir}/config/sql_weights.csv"
  output_csv_file = "#{log_dir}/pg_bench_output.csv"
  unless File.exist?(csv_file)
    puts "CSV file #{csv_file} not found!"
    exit 1
  end

  FileUtils.mkdir_p(log_dir)
  timestamp = Time.now.utc.iso8601
  log_file = "#{log_dir}/pgbench_output_#{timestamp}.log"

  # Seeding phase
  SeedingProcessor.process_seeding_csv(app_dir,"#{app_dir}/config/init.csv", 1)
  SeedingProcessor.process_seeding_csv(app_dir,"#{app_dir}/config/seed_data.csv", 100)
  SeedingProcessor.process_seeding_csv(app_dir,"#{app_dir}/config/seed_uuid_for_update.csv", 1)

  # Run the pgbench test
  exit_status = PGBenchRunner.run_pgbench(app_dir,csv_file, clients, duration, log_file)
  if exit_status == 0
    puts "Load testing completed successfully"
  else
    puts "Load testing failed with exit status #{exit_status}"
    exit 1
  end

  # Process logs and extract metrics
  LogProcessor.process_logs(ENV['TARGET_HOST'], log_file, csv_file, output_csv_file, timestamp, clients, duration)

  puts "-------------------- Summary --------------------"
  puts "Log file: #{log_file}"
  puts "Total connections: #{clients}"
  puts "Duration: #{duration} seconds"
end

main if __FILE__ == $PROGRAM_NAME
