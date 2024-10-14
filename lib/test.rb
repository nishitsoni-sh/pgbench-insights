require 'csv'

# # log_processor.rb
# require 'csv'
#
# module LogProcessor
#   def self.process_logs(log_file, csv_file, output_csv_file, timestamp, clients, duration)
#     # Extract initial connection time
#     initial_connection_time = `grep "initial connection time" #{log_file} | awk -F' = ' '{print $2}' | awk '{print $1; exit}' | xargs`.strip
#
#     # Initialize the row with the common values
#     csv_row = "#{timestamp},#{clients},#{duration},#{initial_connection_time}"
#
#     # Extract metrics for each SQL file and append to the row
#     CSV.foreach(csv_file, headers: false) do |row|
#       table_name, file_name = row.map(&:strip)
#       next if table_name == "table_name" || table_name.nil? || table_name.start_with?('#') || table_name.empty?
#
#       sql_file_path = "sql_statements/#{table_name}/#{file_name}"
#
#
#       total_transactions = `grep -A 5 #{sql_file_path} #{log_file} | grep "transactions"  |grep "total"  | cut -d ' ' -f 3`.strip
#       failed_transactions = `grep -A 5 #{sql_file_path} #{log_file} | grep "failed transactions" | awk '{print $(NF-1)}'`.strip
#       avg_latency = `grep -A 5 #{sql_file_path} #{log_file} | grep "latency average" | awk '{print $(NF-1)}'`.strip
#       stddev_latency = `grep -A 5 #{sql_file_path} #{log_file}  | grep "latency stddev" | awk '{print $(NF-1)}'`.strip
#       tps = `grep -A 5 "statement: #{sql_file_path}" #{log_file} | grep "tps" | awk '{gsub(/[()]/, "", $NF); print $NF}'`.strip
#       puts sql_file_path
#       puts "total_transactions #{total_transactions}"
#       puts "failed_transactions #{failed_transactions}"
#       puts "avg_latency #{avg_latency}"
#       puts "stddev_latency #{stddev_latency}"
#       puts "tps #{tps}"
#
#       csv_row += ",#{total_transactions},#{failed_transactions},#{avg_latency},#{stddev_latency},#{tps}"
#     end
#
#     # Append the completed row to the CSV file
#     File.open(output_csv_file, 'a') { |f| f.puts csv_row }
#   end
# end

# log_processor.rb
require 'csv'

module LogProcessor2
  def self.process_logs(target_host, log_file, csv_file, output_csv_file, timestamp, clients, duration)
    # Initialize totals and counts for aggregations
    totals = {
      "select" => { total_transactions: 0, failed_transactions: 0, avg_latency: 0.0, stddev_latency: 0.0, tps: 0.0, count: 0 },
      "insert" => { total_transactions: 0, failed_transactions: 0, avg_latency: 0.0, stddev_latency: 0.0, tps: 0.0, count: 0 },
      "update" => { total_transactions: 0, failed_transactions: 0, avg_latency: 0.0, stddev_latency: 0.0, tps: 0.0, count: 0 }
    }

    # Extract initial connection time
    initial_connection_time = `grep "initial connection time" #{log_file} | awk -F' = ' '{print $2}' | awk '{print $1; exit}' | xargs`.strip

    # Initialize the row with the common values
    headers = "target_host,timestamp,clients,duration,initial_connection_time"
    csv_row = "#{target_host},#{timestamp},#{clients},#{duration},#{initial_connection_time}"

    # Extract metrics for each SQL file and append to the row
    CSV.foreach(csv_file, headers: false) do |row|
      table_name, file_name = row.map(&:strip)
      next if table_name == "table_name" || table_name.nil? || table_name.start_with?('#') || table_name.empty?

      sql_file_path = "sql_statements/#{table_name}/#{file_name}"

      # Identify operation type based on substring match
      operation_type = if file_name.include?("select")
                         "select"
                       elsif file_name.include?("insert")
                         "insert"
                       elsif file_name.include?("update")
                         "update"
                       else
                         next
                       end

      # Extract the metrics for this operation
      total_transactions = `grep -A 5 #{sql_file_path} #{log_file} | grep "transactions" | grep "total" | cut -d ' ' -f 3`.strip.to_i
      failed_transactions = `grep -A 5 #{sql_file_path} #{log_file} | grep "failed transactions" | awk '{print $(NF-1)}'`.strip.to_i
      avg_latency = `grep -A 5 #{sql_file_path} #{log_file} | grep "latency average" | awk '{print $(NF-1)}'`.strip.to_f
      stddev_latency = `grep -A 5 #{sql_file_path} #{log_file} | grep "latency stddev" | awk '{print $(NF-1)}'`.strip.to_f
      tps = `grep -A 5 #{sql_file_path} #{log_file} | grep "tps" | awk '{gsub(/[()]/, "", $NF); print $NF}'`.strip.to_f

      puts sql_file_path
      puts "total_transactions #{total_transactions}"
      puts "failed_transactions #{failed_transactions}"
      puts "avg_latency #{avg_latency}"
      puts "stddev_latency #{stddev_latency}"
      puts "tps #{tps}"

      # Update totals for the current operation type
      totals[operation_type][:total_transactions] += total_transactions
      totals[operation_type][:failed_transactions] += failed_transactions
      totals[operation_type][:avg_latency] += avg_latency
      totals[operation_type][:stddev_latency] += stddev_latency
      totals[operation_type][:tps] += tps
      totals[operation_type][:count] += 1
    end

    # Calculate averages and append aggregated data to CSV
    totals.each do |operation, metrics|
      headers += "#{operation}_total_transactions,#{operation}_failed_transactions,#{operation}_avg_latency,#{operation}_stddev_latency,#{operation}_tps"
      if metrics[:count] > 0
        avg_latency = metrics[:avg_latency] / metrics[:count]
        stddev_latency = metrics[:stddev_latency] / metrics[:count]

        csv_row += ",#{metrics[:total_transactions]},#{metrics[:failed_transactions]},#{avg_latency},#{stddev_latency},#{metrics[:tps]}"
      else
        # If no matching records, append 0s
        csv_row += ",0,0,0,0,0"

      end
    end
    puts headers
    # Append the completed row to the CSV file
    File.open(output_csv_file, 'a') { |f| f.puts csv_row }
  end
end



log_file="/var/log/my_crons/smoke_test/pgbench_output_2024-10-11T07:42:48Z.log"
csv_file = "/Users/nishitsoni/Documents/code/pgbench-insights/config/sql_weights.csv"
output_csv_file ="/var/log/my_crons/smoke_test/pg_bench_output_test.csv"
clients=10
duration=60
timestamp="2024-10-11T07:42:48Z"
LogProcessor2.process_logs("crunchy",log_file, csv_file, output_csv_file, timestamp, clients, duration)
