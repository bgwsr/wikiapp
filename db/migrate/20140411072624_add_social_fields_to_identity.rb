class AddSocialFieldsToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :full_name, :string, after: :uid
    add_column :identities, :first_name, :string, after: :full_name
    add_column :identities, :last_name, :string, after: :first_name
    add_column :identities, :company_name, :string, after: :last_name
  end
end
