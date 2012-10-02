#######################################################################################################################
#                                              ####     #    ####   #     
#                                              #   #   # #   #   #  #     
#                                              ####   #   #  ####   #     
#                                              # #    #####  #   #  #     
#                                              #  ##  #   #  ####   ##### 
#######################################################################################################################
#
#   Ruby Abstract Bulk Loader
#
#######################################################################################################################
#
# Copyright (c) 2012, REGENTS OF THE UNIVERSITY OF MINNESOTA
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted
# provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this list of conditions and
#   the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
#   the following disclaimer in the documentation and/or other materials provided with the
#   distribution.
# * Neither the name of the University of Minnesota nor the names of its contributors may be used to
#   endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE UNIVERSITY OF MINNESOTA ''AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE UNIVERSITY OF MINNESOTA BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# 
#######################################################################################################################

require 'rainbow'
require 'utilities'

#########
#
#  Rabl 
#
#  A "Rabl" object requires a hash of options passed the call to "new"
#
#    :file => "relative path to the data file in a Rabl-DSL-YAML-format"
#    :delete_all => true/false to delete all existing records before loading
#    :search_columns => a hash of symbols specifying valid column names to search for matching record columns
#
#                       This is representative of any column in your entire dataset that may be used for matching
#                       a referenced object.
#
#                       Example:
#
#                       Table: hotdogs
#
#                       id  |  meat_type_id  |  age  | created_at | updated_at
#                     ------+----------------+-------+------------+-----------
#                        1  |        1       |   3   |  *time*    |  *time*
#
#
#                       Table: meat_types
#
#                       id  |    meat   | created_at | updated_at
#                     ------+-----------+------------+------------
#                        1  |  mystery  |  *time*    |  *time*
#                    
#
#                      Assume that meat_types was loaded in first with a structure like:
#
#                      meat_types:
#                        - 
#                          meat: mystery
#
#                      Then later in the data file, you have a hotdog object specified like this:
#
#                      hotdogs:
#                        -
#                          age: 3
#                          meat_type_id: "mystery"
#
#                      your :search_columns hash would look like => {:meat => true}
#
#    :special_search_column_logic => by default, it is a simple lambda that returns true or false based on certain conditions
#
#                                    It takes the form:
#
#                                    lambda { |k, column_type, special_column, val|  }
# 
#                                    k              = a single key obtained from a keys.keep_if {|k| lambda_gets_called_here }
#                                    column_type    = ActiveRecord->columns[:single_column]->type
#                                    special_column = one of the columns listed in option hash ":special_columns"
#                                    val            = individual value from an item/entry in the data file
#
#    :special_columns => hash of columns that may have different types in different ActiveModels
#                        For example, in TerraPop, one table has "code" as type integer, while another
#                        table has "code" as a string 
#

module Proprietas
  
  class Rabl
    # shoveling data and datar-tots into TerraPop
  
    # these are needed to make Devise-based "User" work correctly
  
    include Rails.application.routes.url_helpers
    include Rails.application.routes.mounted_helpers
  
    attr_accessor :data, :objects, :search_columns, :special_search_column_logic, :special_columns
    attr_accessor :issues, :options, :debug, :dry_run, :cache_enabled, :transaction_enable
  
    VALID_OPERS       = { :or => true, :and => true }
    SPECIAL_KEYS      = { "_config" => true }
  
    def initialize(*options)
      self.options = _config(options)
    
      Utilities.wait_spinner {
        self.data = YAML.load_file( self.options[:file] )
      }
    
      path = File.dirname(File.expand_path(self.options[:file]))
    
      SPECIAL_KEYS.each do |key,val|
        if self.data.include? key
          if key == "_config"
            if self.data[key].class == Hash
              if self.data[key]['include'].class == Array
                self.data[key]['include'].each do |file|
                  self.data.merge!(YAML.load_file(File.join(path, file)))
                end
              end
            end
          end
        end
      end
        
      # open wide - this will generate a LOT of SQL output if enabled.
    
      ActiveRecord::Base.logger = Logger.new(STDOUT) if self.debug > 3
    
    end

    def scoop
    
      ActiveRecord::Base.connection.enable_query_cache!
    
      Database::Transaction.block( self.transaction_enable ) do
      
        $stderr.puts ""
      
        #if options[:delete_all]
        #  
        #  Hash[data.reverse_each.map{|e| e}].each do |key,dat|
        #    obj = key.singularize.camelize.constantize
        #    obj.delete_all
        #  end
        #  
        #end
      
        data.each do |key,dat|
        
          unless SPECIAL_KEYS.include? key
          
            obj = ar = nil
      
            begin
              name = key.singularize.camelize
              $stderr.print "     + Working on #{name}".widthize(48) + "(#{dat.count} objects)  ".color(:yellow)
        
              # Get the class object for the class named 'name'.
              obj = name.constantize
              obj.delete_all if options[:delete_all]
            rescue Exception => e
              $stderr.puts "#{e}"
            end
        
            Utilities.wait_spinner(self.debug) {
              _load_data(dat, obj)
            }
        
            $stderr.puts ""
        
          end
        
        end
    
      end # commit the transaction assuming it all went in correctly.
    
    end
    
    #def method_missing(m, *args, &block)  
    #$stderr.puts "Oh No! #{m} is not a method on this object"  
    #end  
  
    private 
  
    # load all the records for one entity type.
    # if requires_extra_work is false, they can be inserted directly.
    # If it's true, then call _load_single_instance which can look up the appropriate foreign keys and do the insert.
    def _load_data(dat, obj)
      $stderr.puts("Creating a new Cache for instances of #{obj}") if self.debug > 1
      cache = ActiveSupport::Cache::MemoryStore.new()
      dat.each do |row|
        ar = obj.new
        # if requires_extra_work
          _load_single_instance(ar, row, cache)
        #else
        #  row.each do |k,v|
        #    ar.send(k + "=", v)
        #  end
        #  ar.save
        # end
      end
    end
    
    # Load a single record for one entity type.
    # dat is a Hash of the properties for this entity.
    # Keep the result of foreign key lookups in a cache, to minimize redundant database hits.
    def _load_single_instance(record_obj, dat, cache )
    
      dat.each do |k,v|
        key = k.downcase

        $stderr.puts("TRACE: _load_single_instance top: key:#{key}, v:#{v}") if self.debug > 2
      
        if key.match /_id$/
          # we need to go find a single foreign key value. Cache it if we can.
          if self.cache_enabled & cache.exist?(v)
            $stderr.puts("Found #{key}:#{v} in the cache") if self.debug > 2
            resolved_val = cache.read(v)
          else
            # TODO - if record_obj.association(:k).reflection.options(:class_name) is not null, then we need to use that as the class name for doing the lookup.
            k_sym = k.sub(/_id$/, '').intern
            # check to make sure that there's actually an AR association in place before trying to resolve it.
          
            foreign_table_assoc = record_obj.class.reflect_on_association(k_sym)
          
            if foreign_table_assoc.nil?
              $stderr.puts("WARN: #{key} doesn't have a matching association - are you missing a has_many or belongs_to in #{record_obj.class}?")
              foreign_table = nil
            else
              foreign_table = record_obj.association(k_sym).reflection.options[:class_name]
            end
          
            if (foreign_table.nil?)
              resolved_val = _resolve_ids(key, v)
            else
              $stderr.puts("TRACE: #{key} points to foreign key #{foreign_table}") if self.debug > 2
              foreign_table_id = foreign_table.downcase + "_id"
              $stderr.puts("TRACE: Trying to resolve #{key} as if it were #{foreign_table_id}") if self.debug > 1
              resolved_val = _resolve_ids(foreign_table_id, v)
              $stderr.puts("TRACE: Found #{resolved_val}.") if self.debug > 2
            end
            cache.write(v, resolved_val) if self.cache_enabled
          end
        elsif key.match /_ids$/
          # Look for has_many_and_belongs_to_many relationships
          key_stub = key.sub(/_ids$/, '')
          to_many_key = key_stub.singularize.camelize
          $stderr.puts("TRACE: k: #{to_many_key}, v: #{v}") if self.debug > 3

          # get the subkeys for each element of the value
          if v.class == Array
            subkeys = v.collect { |subv| _resolve_ids(to_many_key, subv) }
            $stderr.puts("TRACE: subkeys for #{to_many_key} are: #{subkeys}") if self.debug > 3
          end
      
          # set up state for the record_obj.send call below.
          # the key from the yaml file is actually correct to begin with.
          # given a key of agg_data_var_group_ids, the collection name will be agg_data_var_groups
          # and the method to set the collection using explicit primary ids is agg_data_var_group_ids
          resolved_val = subkeys
      
        elsif key.match /^parent$/
          unless v.nil?
            # pass in the class of record_obj - we just need a clean/fresh class object
            # because we are dealing with a 'parent' record, we just need to use the same
            # class type - because we need to use class methods to locate the id of the parent
            # of this record.  (I think...) -acj
            resolved_val = _resolve_ids(key, v, "OR", record_obj.class)  
            key = key + "_id"
          end
        else
          resolved_val = v
        end
      
        # now that we've got the key and value for this field, set it on the object.
        $stderr.puts("TRACE: setting #{key} to: #{resolved_val}") if self.debug > 3
      
        record_obj.send(key + "=", resolved_val)
      end
    
      # after processing all the elements for this object in the yaml file, save the object.
      record_obj.save if record_obj.changed?
    end
  
  
    def _resolve_ids(key, val, bool_oper = "OR", obj = nil)
      # We're looking for an object of type 'key' that has primary keys of 'val'. Val may be a hash, or it may be a value.
      $stderr.puts "TRACE: digging for Key: #{key.to_s}, Val: #{val.to_s}" if self.debug > 4
  
      unless VALID_OPERS.include? bool_oper.downcase.to_sym
        bool_oper = "OR"
      end
    
      if val.class == Array
      
        vals = {}
      
        val.each do |v|
        
          if v.class == Hash
          
            v.each do |sub_key, sub_val|
            
              vals[sub_key] = _resolve_ids(sub_key, sub_val)
            
            end
          
          else
            raise "#{v} invalid syntax; expected Hash but found #{v.class.to_s}"  
          end
                
        end
      
        return _resolve_ids(key, vals, 'AND') # vals
      
      else
    
        if obj.nil?
          class_name = key.sub(/_id$/, '').singularize.camelize
          obj = class_name.constantize
        end
      
        unless bool_oper.casecmp("and") == 0 and val.class == Hash

          ar = obj.new
          keys = ar.attributes.keys.keep_if { |k| search_columns.include? k.to_sym }
        
          if special_search_column_logic.class == Proc
            special_columns.each do |c|
              if ar.attributes.include? c
              
                keys = keys.keep_if { |k| special_search_column_logic.call(k, ar.column_for_attribute(c).type, c, val) }

              end
            end
          end
        
          # construct a WHERE clause to deal with looking up the foreign key requested in the call
          where_str = keys.join(" = ? #{bool_oper} ") + " = ?"

          vals      = ([val.to_s] * keys.size)      
          val_obj   = obj.where([where_str, *vals])
        
        else
        
          val_obj = obj.where(val)
        
        end
      
        unless val_obj.nil?
        
          if val_obj.count == 1
            val = val_obj.first.id
          else
          
            message = "ERROR:\n\n".color(:red).bright
          
            message << "The following query returned #{val_obj.count} records:\n\n"
          
            message << val_obj.to_sql 
          
            message << "\n\n"
          
            raise message
          
          end
        
        else
          raise "val_obj is nil for #{where_str} on #{obj.to_s} with '#{vals}'"
        end
    
        val
    
      end
    
    end
  
    def _config(options)
    
      self.issues = []
    
      options = options[0] if options.size > 0
    
      unless options[:debug]
        self.debug = 0
      else
        self.debug = options[:debug]
      end
    
      unless ENV['DEBUG'].nil?
        self.debug = ENV['DEBUG'].is_i? ? ENV['DEBUG'].to_i : 0
      end
    
      unless options.include? :file
        self.issues << "+ A YAML data file was not specified."
      end
  
      if options[:objects] and options[:objects].class == Hash
        self.objects = options[:objects]
      elsif options[:objects] and options[:objects].class != Hash
        self.issues << "+ :objects is required to be of type Hash"
      else
        self.objects = {}
      end
  
      if options[:search_columns] and options[:search_columns].class == Hash
        self.search_columns = options[:search_columns]
      elsif options[:search_columns] and options[:search_columns].class != Hash
        self.issues << "+ :search_columns is required to be of type Hash"
      else
        self.search_columns = {}
      end
    
      unless options[:special_search_column_logic]
      
        self.special_search_column_logic = lambda { |k, column_type, special_column, val| 
            if k.casecmp(special_column) == 0 and column_type != :string and val.to_s.is_i?
              true
            elsif k.casecmp(special_column) == 0 and column_type == :string
              true
            elsif k.casecmp(special_column) != 0
              true
            else
              false
            end
          }

      else
        self.special_search_column_logic = options[:special_search_column_logic]
      end
    
      unless options[:special_columns]
        self.special_columns = []
      else
        self.special_columns = options[:special_columns]
      end
    
      if self.issues.size > 0
        raise "Error(s): " + issues.join("\n")
      end
    
      unless options[:cache_enabled]
        self.cache_enabled = false
      else
        self.cache_enabled = options[:cache_enabled]
      end

      unless options[:dry_run]
        self.dry_run = false
      else
        self.dry_run = options[:dry_run]
      end
    
      unless options[:transaction_enable]
        self.transaction_enable = true
      else
        self.transaction_enable = options[:transaction_enable].is_bool? ? options[:transaction_enable] : true
      end
    
      unless ENV['TRANSACTION_ENABLE'].nil?
        self.transaction_enable = ENV['TRANSACTION_ENABLE'].is_bool? ? ENV['TRANSACTION_ENABLE'].to_bool : true
      end
    
      if self.dry_run 
        $stderr.puts "\n\nDry Run Enabled\n\n".bright
      end
    
      options
    end
  end
end