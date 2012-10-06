class CreateHomesteadCodes < ActiveRecord::Migration
  def change
    create_table :homestead_codes do |t|
      t.column      :code,     :integer
      t.column      :name,     :string, :limit => 128
      t.column      :mnemonic, :string, :limit => 16
      t.timestamps
    end
  end
end
