module ActiveRecord
  module ConnectionAdapters
  
    PostgreSQLAdapter.class_eval do
      
      alias :original_native_database_types                   :native_database_types
      alias :original_disable_referential_integrity           :disable_referential_integrity
      alias :original_quote                                   :quote
            
      def native_database_types
        {
          :primary_key => { :name => "bigserial primary key" },
          :string      => { :name => "character varying", :limit => 255 },
          :text        => { :name => "text" },
          :integer     => { :name => "integer" },
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
      
      #Redefines the quote method to add behaviour for when a Geography is encountered
      def quote(value, column = nil)
        
        if ! column.nil? and column.type == :geography
          new_value = "ST_GeogFromWKB('\\x#{value}')"
        else
          new_value = original_quote(value,column)
        end
        
        new_value
      end
      
    end
    
    ##################################################
    
    # put some logic into PostgreSQLColumn to notice when we're working with geography types.
    PostgreSQLColumn.class_eval do

      alias :original_simplified_type :simplified_type

      private
      #Redefines the simplified_type method to add behaviour for when a column is of type geometry
      def simplified_type(field_type)
        case field_type
          when /geography/i then :geography
          else original_simplified_type(field_type)
        end
      end

    end
  end
end