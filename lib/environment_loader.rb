module EnvironmentLoader
  def self.load_env(file_path)
    if File.exist?(file_path)
      File.foreach(file_path) do |line|
        key, value = line.strip.split('=', 2)
        ENV[key] = value if key && value
      end
    else
      puts "Environment config file #{file_path} not found!"
      exit 1
    end
  end
end
