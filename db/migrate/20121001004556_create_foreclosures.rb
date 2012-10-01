class CreateForeclosures < ActiveRecord::Migration
  def change
    create_table :foreclosures do |t|
      t.column  :parid,         :string, :limit => 64	
      t.column  :luc,           :integer               # Land Use Code
      t.column  :muni,          :string, :limit => 8	
      t.column  :nbhd,          :string, :limit => 16	
      t.column  :hstdcode,      :integer
      t.column  :censusblk,     :integer	
      t.column  :zip5,          :string, :limit => 5	
      t.column  :zip4,          :string, :limit => 4	
      t.column  :case_no,       :integer	
      t.column  :attorney,      :text	
      t.column  :sale_dt,       :date	
      t.column  :soldto,        :text	
      t.column  :sale_amt,      :decimal, :precision => 16, :scale => 4
      t.column  :paid_amt,      :decimal, :precision => 16, :scale => 4	
      t.column  :addrln1,       :string, :limit => 254	
      t.column  :addrln2,       :string, :limit => 254	
      t.column  :city,          :string, :limit => 128	
      t.column  :statezip,      :string, :limit => 4	
      t.column  :buyer_addrno,	:string, :limit => 254
      t.column  :buyer_addrln1, :string, :limit => 254	
      t.column  :buyer_addrln2, :string, :limit => 254	
      t.column  :buyer_city,    :string, :limit => 128	
      t.column  :buyer_state,   :string, :limit => 4	
      t.column  :buyer_zip,     :string, :limit => 16
      t.column  :entrydate,     :date
      t.column  :county_id,     :bigint
      t.timestamps
    end
  end
end
