# lib/elevation_data/query_runner.rb
require 'pg'
require 'benchmark'
require_relative 'environment_loader'

module ElevationData
  class QueryRunner
    def initialize(db_params, table_name, sample_count = 1000)
      @conn = PG.connect(db_params)
      @table_name = table_name
      @sample_count = sample_count
      @latencies = []
    end

    def bounding_box
      # Using ST_EstimatedExtent for efficient bounding box estimation on large datasets
      query = <<-SQL
        SELECT ST_EstimatedExtent('#{@table_name}', 'geom') AS bbox
      SQL
      result = @conn.exec(query).first['bbox']
      parse_bounding_box(result)
    end

    def first_record
      query = <<-SQL
        SELECT * from #{@table_name} limit 1
      SQL
      puts @conn.exec(query).inspect
    end

    def random_coordinate_within_bbox(bbox)
      rand_x = rand(bbox[:min_x]..bbox[:max_x])
      rand_y = rand(bbox[:min_y]..bbox[:max_y])
      [rand_x, rand_y]
    end

    def run_queries
      bbox = bounding_box
      @sample_count.times do
        coord_x, coord_y = random_coordinate_within_bbox(bbox)
        time = Benchmark.realtime do
          execute_nearest_neighbor_query(coord_x, coord_y)
        end
        @latencies << (time * 1000)  # Convert to ms
      end
    ensure
      @conn.close
    end

    def latencies
      @latencies
    end

    private

    def execute_nearest_neighbor_query(coord_x, coord_y)
      query = <<-SQL
        SELECT *, ST_Distance(geom, ST_SetSRID(ST_MakePoint($1, $2), 4326)) AS distance
        FROM #{@table_name}
        ORDER BY geom <-> ST_SetSRID(ST_MakePoint($1, $2), 4326)
        LIMIT 1;
      SQL
      @conn.exec_params(query, [coord_x, coord_y])
    end

    def parse_bounding_box(bbox_str)
      bbox_str.match(/\((.*),(.*)\),\((.*),(.*)\)/)
      {
        min_x: Regexp.last_match(1).to_f,
        min_y: Regexp.last_match(2).to_f,
        max_x: Regexp.last_match(3).to_f,
        max_y: Regexp.last_match(4).to_f
      }
    end
  end
end
