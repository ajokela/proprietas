class Region < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :country
end
