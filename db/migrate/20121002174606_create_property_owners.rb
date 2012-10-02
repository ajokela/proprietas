class CreatePropertyOwners < ActiveRecord::Migration
  def change
    create_table :property_owners do |t|
      t.column      :name,        :string, :limit => 128
      t.column      :property_id, :bigint
      t.timestamps
    end
  end
end
