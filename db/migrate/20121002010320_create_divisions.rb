class CreateDivisions < ActiveRecord::Migration
  def change
    create_table :divisions do |t|
      t.column      :name,                  :string, :limit => 128
      t.column      :division_geocode_num,  :integer
      t.column      :region_id,             :bigint
      t.timestamps
    end
    
    foreign_key :divisions, :region_id
    
  end
end
