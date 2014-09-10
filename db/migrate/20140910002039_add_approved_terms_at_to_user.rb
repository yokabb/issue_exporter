class AddApprovedTermsAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :approved_terms_at, :datetime
  end
end
