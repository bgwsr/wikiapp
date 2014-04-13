class AddSilkIdIndexToSubmissions < ActiveRecord::Migration
  def change
    add_index :submissions, [:silk_identifier, :status]
  end
end
