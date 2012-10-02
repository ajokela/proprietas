require 'active_support'

module ActiveRecord  
  class Migration

    def foreign_key(from_table, from_column)
        
      to_table = from_column.to_s.sub(/_id$/, '').pluralize
        
      constraint_name = "#{from_table}_#{from_column}_fkey" 

      execute %{alter table #{from_table}
                add constraint #{constraint_name}
                foreign key (#{from_column})
                references #{to_table}(id)}

    end
  
    def foreign_key_raw(from_table, from_column, to_table, to_column )

      constraint_name = "#{from_table}_#{from_column}_fkey" 

      execute %{alter table #{from_table}
                add constraint #{constraint_name}
                foreign key (#{from_column})
                references #{to_table}(#{to_column})}

    end
  
    def remove_constraint(from_table, constraint_name)
    
      execute %{alter table #{from_table} DROP CONSTRAINT #{constraint_name}}
    
    end
  
    def add_index_raw(table, columns, is_unique = false)

      index_name = columns.join("_")
    
      index_name = "#{table}_#{index_name}_idx"
        
      if columns.size > 1
        columns_str = columns.join(", ")
      else
        columns_str = columns
      end
    
      if is_unique
        unique = "UNIQUE"
      else
        unique = ""
      end
    
      execute %{CREATE #{unique} INDEX #{index_name} ON #{table} (#{columns_str})}
    
    end

  end
end