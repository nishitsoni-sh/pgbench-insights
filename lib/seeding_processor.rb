# seeding_processor.rb
require 'csv'

module SeedingProcessor
  def self.process_seeding_csv(app_dir, seeding_csv, transaction_count)
    puts "Starting the seeding phase for #{seeding_csv} with #{transaction_count} transactions..."

    CSV.foreach(seeding_csv, headers: false) do |row|
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

      puts "Running pgbench for seeding with #{sql_file_path}, weight #{weight}, and transaction count #{transaction_count}"
      puts "Command ## PGPASSWORD=#{ENV['PGPASS']} pgbench -h #{ENV['PGHOST']} -p #{ENV['PGPORT']} -U #{ENV['PGUSER']} -d #{ENV['PGDATABASE']} -n -c 1 -f #{sql_file_path} -t #{transaction_count}"
      system("PGPASSWORD=#{ENV['PGPASS']} pgbench -h #{ENV['PGHOST']} -p #{ENV['PGPORT']} -U #{ENV['PGUSER']} -d #{ENV['PGDATABASE']} -n -c 1 -f #{sql_file_path} -t #{transaction_count} > /tmp/seed.log 2>&1")

      unless $?.success?
        puts "Seeding failed at #{seeding_csv} (#{sql_file_path} step)"
        exit 1
      end
    end
  end
end
