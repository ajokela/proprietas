class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.column      :name,       :string, :limit => 128
      t.column      :area_miles, :bigint
      t.timestamps
    end
        
  end
end
