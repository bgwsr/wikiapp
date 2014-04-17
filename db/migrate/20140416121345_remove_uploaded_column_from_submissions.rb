class RemoveUploadedColumnFromSubmissions < ActiveRecord::Migration
  def change
    remove_column :submissions, :uploaded
  end
end
