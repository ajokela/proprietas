require 'csv'

module Proprietas
  class UniqueMnemonic
    attr_accessor :infile, :options, :table, :mnemonic_basis, :mnemonic_min_length, :_line
    
    def initialize(_options)
      
      @infile = _options[:infile]
      @options= _options
      
      @_line = 0
      
      if options[:mnemonic_min_length].nil?
        raise "Mnemonic minimum length required"
      elsif options[:mnemonic_min_length].class == Fixnum
        @mnemonic_min_length = options[:mnemonic_min_length]
      else
        raise "Mnemonic minimum length must be integer"
      end
      
      if options[:mnemonic_basis].nil?
        raise "Mnemonic basis (e.g. which column to use) is required"
      elsif options[:mnemonic_basis].class == Fixnum
        @mnemonic_basis = options[:mnemonic_basis]
      else
        raise "Mnemonic basis (e.g. which column to use) must be integer (::mnemonic_basis)"
      end
      
    end
    
    def process
      @table = []
      
      CSV.foreach(infile) do |row|
        @table << row
        _generate_mnemonic
        @_line += 1
      end
      
      @table
    end
    
    private
    def _generate_mnemonic
      
      if mnemonic_basis >= table.last.size 
        raise "Mnemonic basis is greater than columns on line #{_line}"
      end
      
      long_string = table.last[mnemonic_basis]
      
      proposed_mnemonic = ''
      bytes = [] # Byte array
      long_string = ' ' + long_string # so the first letter, if capital, is included
      long_string.each_byte {|byte| bytes.push(byte)} # Build array of bytes
      bytes.each_with_index do |byte, index|
        if byte > 64 and byte < 96 # This is the range for ASCII capital letters, your encoding may vary
          # Capital letter
          if [32, 40, 45, 47].include? bytes[index-1] # is letter preceded by a space or '(' or "-" or "/"
            proposed_mnemonic = proposed_mnemonic + long_string[index,1]
          end
        end
      end
      
      while proposed_mnemonic.length < mnemonic_min_length
        proposed_mnemonic += 'X'
      end
      
      # check for uniqueness
      
      mnemonic = _generate_unique_mnemonic(proposed_mnemonic)
      
      table.last << mnemonic
      
    end
    
    def _generate_unique_mnemonic(proposed_mnemonic)
      unique = true
      for i in (0...table.size-1)
        mnemonic = table[i][mnemonic_basis+1]
        if mnemonic == proposed_mnemonic
          unique = false
          break
        end
      end
      
      unless unique
        _generate_unique_mnemonic(proposed_mnemonic + 'X')
      else
        proposed_mnemonic
      end
    end

  end
end