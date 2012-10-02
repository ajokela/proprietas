class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.column      :name,    :string, :limit => 128
      t.timestamps
    end
        
  end
end
