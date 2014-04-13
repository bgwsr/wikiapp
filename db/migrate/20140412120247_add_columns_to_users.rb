class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ambassador, :boolean, default: false, after: :email
    add_column :users, :countries, :string, after: :ambassador
    add_index :users, :countries
  end
end
