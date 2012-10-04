require 'proprietas/translate/unique_mnemonic'

module Proprietas
  class CsvYml
    attr_accessor :options, :unique_mnemonic
    
    def initialize(options)
      # options = {:infile => 'data/raw/RamseyCountyMN_HomesteadCodes.csv', :outfile => 'outfile', :mnemonic_min_length => 5, :mnemonic_basis => 1, :table => 'foobars', :columns => [:code, :name, :mnemonic]}
      
      @options = options
      @unique_mnemonic = UniqueMnemonic.new(options)
      
    end
    
    def process(with_unique_mnemonic = true)
      
      if with_unique_mnemonic
        table    = unique_mnemonic.process
      else
        table    = CSV.read(options[:infile])
      end
      
      columns  = options[:columns]
      yable    = []  # yaml table
      
      table.each{ |line| 
        hash_line= {}
        line.each_with_index { |d,i| hash_line[columns[i].to_s] = d }
        yable << hash_line
      }
      
      File.open(options[:outfile], 'w') {|f| f.write({options[:table] => yable}.to_yaml)}
      
    end
  
  end
end
