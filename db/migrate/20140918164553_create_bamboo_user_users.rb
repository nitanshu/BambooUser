class CreateBambooUserUsers < ActiveRecord::Migration
  def change
    create_table :bamboo_user_users do |t|
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
