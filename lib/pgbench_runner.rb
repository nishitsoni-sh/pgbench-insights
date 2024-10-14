# pgbench_runner.rb
require 'csv'

module PGBenchRunner
  def self.run_pgbench(app_dir,csv_file, clients, duration, log_file)
    pgbench_cmd = "PGPASSWORD=#{ENV['PGPASS']} pgbench -h #{ENV['PGHOST']} -p #{ENV['PGPORT']} -U #{ENV['PGUSER']} -d #{ENV['PGDATABASE']} -n -c #{clients} -T #{duration}"

    CSV.foreach(csv_file, headers: false) do |row|
      table_name, file_name, weight = row.map(&:strip)

      next if table_name.nil? || table_name.start_with?('#') || table_name.empty?

      sql_file_path = "#{app_dir}/sql_statements/#{table_name}/#{file_name}"

      unless File.exist?(sql_file_path)
        puts "SQL file #{sql_file_path} not found! Skipping..."
        next
      end

      weight = weight.strip
      unless weight.to_i > 0
        puts "Invalid or zero weight for #{sql_file_path}. Skipping..."
        next
      end

      pgbench_cmd += " -f #{sql_file_path}@#{weight}"
      puts "Added #{sql_file_path} with weight #{weight} to pgbench command."
    end

    pgbench_cmd += " > #{log_file} 2>&1"
    puts "Executing pgbench: #{pgbench_cmd}"
    system(pgbench_cmd)

    $?.exitstatus
  end
end
