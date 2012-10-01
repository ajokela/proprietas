class CreateCounties < ActiveRecord::Migration
  def change
    create_table :counties do |t|
      t.column      :name,        :string, :limit => 128
      t.column      :fipscode,    :integer
      t.column      :county_seat, :string, :limit => 128
      t.column      :established, :integer
      t.column      :origin,      :text
      t.column      :etymology,   :text
      t.column      :area_miles,  :bigint
      t.timestamps
    end
  end
end
