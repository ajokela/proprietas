class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|

      t.column  :parid,         :string, :limit => 64	
      t.column  :luc,           :integer               # Land Use Code
      t.column  :muni,          :string, :limit => 8	
      t.column  :nbhd,          :string, :limit => 16	
      t.column  :hstdcode,      :integer
      t.column  :censusblk,     :integer	
      t.column  :zip5,          :string, :limit => 5	
      t.column  :zip4,          :string, :limit => 4	      
      t.column  :addrln1,       :string, :limit => 254	
      t.column  :addrln2,       :string, :limit => 254	
      t.column  :city,          :string, :limit => 128	
      t.column  :statezip,      :string, :limit => 4
      t.column  :county_id,     :bigint
      
      t.column  :latitude,      :decimal, :precision => 16, :scale => 13
      t.column  :longitude,     :decimal, :precision => 16, :scale => 13
      
      t.timestamps
    end
  end
end
