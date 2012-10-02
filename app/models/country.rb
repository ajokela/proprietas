class Country < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :regions
  has_many :divisions, :through => :regions
  
end
