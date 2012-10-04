class CreateMunicipalities < ActiveRecord::Migration
  def change
    create_table :municipality_divisions do |t|
      t.column      :code,    :string, :limit => 4
      t.column      :name,    :string, :limit => 128
      t.timestamps
    end
  end
end
