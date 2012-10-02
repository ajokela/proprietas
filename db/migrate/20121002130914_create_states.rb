class CreateStates < ActiveRecord::Migration
  def change
    
    create_table :states do |t|
      t.column    :division_id,  :bigint
      t.column    :fips,   :integer
      t.column    :name,   :string, :limit => 128
      t.timestamps
    end

    foreign_key :counties, :state_id
    foreign_key :states,   :division_id
    
  end
end
