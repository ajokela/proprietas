class CreateHomesteadCodes < ActiveRecord::Migration
  def change
    create_table :homestead_codes do |t|

      t.timestamps
    end
  end
end
