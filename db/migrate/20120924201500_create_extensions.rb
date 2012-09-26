class CreateStates < ActiveRecord::Migration
  def change
    execute("CREATE EXTENSION postgis")
    execute("CREATE EXTENSION postgis_topology")
  end
end
