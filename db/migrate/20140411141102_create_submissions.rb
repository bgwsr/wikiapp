class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.string :silk_identifier
      t.references :user, index: true
      t.integer :moderator_id
      t.boolean :uploaded, default: false
      t.string :status, limit: 30, default: "pending"
      t.text :content

      t.timestamps
    end
  end
end
