class AddApprovedTermsToUser < ActiveRecord::Migration
  def change
    add_column :users, :approved_terms, :boolean
  end
end
