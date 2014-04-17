class CreateArchives < ActiveRecord::Migration
  def change
    create_table :archives do |t|
      t.string :silk_identifier
      t.string :country
      t.integer :user_id
      t.integer :moderator_id
      t.string :status
      t.text :content

      t.timestamps
    end
  end
end
