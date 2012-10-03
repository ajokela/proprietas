
module ActiveRecord
  module ConnectionAdapters
    
    PostgreSQLAdapter.class_eval {
      
      @@native_database_types = nil
      
      alias :original_quote :quote
            
      def native_database_types
        @@native_database_types = {
          :primary_key => { :name => "bigserial primary key" },
          :string      => { :name => "character varying", :limit => 255 },
          :text        => { :name => "text" },
          :integer     => { :name => "bigint" },
          :float       => { :name => "float" },
          :decimal     => { :name => "decimal" },
          :datetime    => { :name => "timestamp" },
          :timestamp   => { :name => "timestamp" },
          :time        => { :name => "time" },
          :date        => { :name => "date" },
          :binary      => { :name => "bytea" },
          :boolean     => { :name => "boolean" },
          :bigint      => { :name => "int8" },
          :spatial     => { :name => "geography(MultiPolygon, 4326)" },
          :raster      => { :name => "raster" }
        }
        @@native_database_types
      end
          
      def quote(value, column = nil)        
        if ! column.nil? and column.type == :geography
          %{ST_GeogFromWKB('\\x#{value}')}
        elsif value.is_a?(::RGeo::Cartesian::BoundingBox)
          "'#{value.min_x},#{value.min_y},#{value.max_x},#{value.max_y}::box'"
        else
          original_quote(value, column)
        end
      end
    }
    
    PostgreSQLColumn.class_eval {

      alias :original_simplified_type :simplified_type
      private
      def simplified_type(field_type)
        field_type =~ /geography|geometry|point|linestring|polygon/i ? :spatial : original_simplified_type(field_type)        
      end

    }
    
  end
end