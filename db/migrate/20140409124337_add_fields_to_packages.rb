class AddFieldsToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :title, :string
    add_column :packages, :published_at, :datetime
    add_column :packages, :author, :string
    add_column :packages, :maintainer, :string
    add_column :packages, :description, :text
    add_column :packages, :dependencies, :text
  end
end
