class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.column  :name,                :string, :limit => 128
      t.column  :region_geocode_num,  :integer
      t.column  :country_id,          :bigint
      t.timestamps
    end
    
    foreign_key :regions, :country_id
    
  end
end
