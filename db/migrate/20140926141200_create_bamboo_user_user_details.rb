class CreateBambooUserUserDetails < ActiveRecord::Migration
  def change
    create_table :bamboo_user_user_details do |t|
      t.integer :user_id
      #---Add other required attributes [START]----
      #like
      #t.string :first_name
      #t.string :last_name
      #---Add other required attributes [END]----
      t.timestamps
    end
  end
end
