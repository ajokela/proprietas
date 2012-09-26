class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.column    :name,   :string, :limit => 128
      t.timestamps
    end
  end
end
