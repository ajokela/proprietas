class CreateLandUseCodes < ActiveRecord::Migration
  def change
    create_table :land_use_codes do |t|

      t.timestamps
    end
  end
end
