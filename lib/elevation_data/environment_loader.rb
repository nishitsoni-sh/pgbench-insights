# lib/elevation_data/environment_loader.rb
require 'pg'

module ElevationData
  class EnvironmentLoader
    def self.load_database_params
      {
        host: ENV['DB_HOST'] || 'p.6upifuy6kfblfbmbngbn3mwa4e.db.postgresbridge.com',
        port: ENV['DB_PORT'] || 5432,
        dbname: ENV['DB_NAME'] || 'postgres',
        user: ENV['DB_USER'] || 'application',
        password: ENV['DB_PASSWORD'] || 'e2BzD4XyU7au2nqRW2XwY0DfayuL6BOOugOgt8qIqAPOwXB2UwNuql6XJjvPZsCV'
      }
    end

    def self.table_name
      ENV['ELEVATION_DATA_TABLE_NAME'] || 'public.xyz_elevation_data_large_mv'
    end
  end
end