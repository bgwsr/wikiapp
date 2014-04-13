class AddCountryToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :country, :string, limit: 200, null: false, after: :silk_identifier
    add_index :submissions, :country
  end
end
