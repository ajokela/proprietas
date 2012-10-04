class CreateMunicipalDivisions < ActiveRecord::Migration
  def change
    create_table :municipal_divisions do |t|
      t.column      :code,     :string, :limit => 4
      t.column      :name,     :string, :limit => 128
      t.column      :mnemonic, :string, :limit => 16
      t.timestamps
    end
  end
end
