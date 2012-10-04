module Proprietas
  
  module Utilities

    module Transaction
      
      def self.block(enable, &b)
      
        if enable
          ActiveRecord::Base.transaction do
            b.call
          end
        else
          b.call
        end
        
      end
      
    end
      
    def self.wait_spinner( args = {} )
    
      defaults = {:fps=> 10, :enable => true, :debug => 0}
      
      if args.class == Hash
        args = defaults.merge(args)
      else
        args = defaults
      end
      
      chars = %w[| / - \\]
      delay = 1.0/args[:fps].to_f
      iter = 0
            
      unless ENV["RAILS_ENV"].nil?
        if ENV["RAILS_ENV"].match(/test/)
          args[:enable] = false
        end
      end
            
      if args[:enable]
      
        spinner = Thread.new do
          while iter do  # Keep spinning until told otherwise
            $stderr.print chars[(iter+=1) % chars.length]
            sleep delay
            $stderr.print "\b"
          end
        end
    
        yield.tap{       # After yielding to the block, save the return value
          iter = false   # Tell the thread to exit, cleaning up after itself…
          spinner.join   # …and wait for it to do so.
        }                # Use the block's return value as the method's
      
      else
        yield if block_given?
      end
      
    end  
    
  end
  
end