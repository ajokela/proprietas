
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
          :geography   => { :name => "geography(MultiPolygon, 4326)" },
          :raster      => { :name => "raster" }
        }
        @@native_database_types
      end
    
      def supports_disable_referential_integrity?
        false
      end
        
      def disable_referential_integrity(&block)
        transaction {
          begin
            execute "SET CONSTRAINTS ALL DEFERRED"
            yield if block_given?
          ensure
            execute "SET CONSTRAINTS ALL IMMEDIATE"
          end
        }
      end
      
      def quote(value, column = nil)
        
        if ! column.nil? and column.type == :geography
          val = "ST_GeogFromWKB('\\x#{value}')"
        else
          val = original_quote(value,column)
        end
        
        val
      end
      
    end
    
    ##################################################
    
    PostgreSQLColumn.class_eval {

      alias :original_simplified_type :simplified_type

      private

      def simplified_type(field_type)
        case field_type
          when /geography/i then :geography
          else original_simplified_type(field_type)
        end
      end

    }
    
  end
end