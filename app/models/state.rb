class State < ActiveRecord::Base
  # attr_accessible :title, :body
  
  belongs_to :country
  belongs_to :region
  belongs_to :division
  
end
