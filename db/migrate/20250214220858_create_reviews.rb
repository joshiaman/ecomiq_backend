class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.integer :rating, null: false   # Rating should always be present
      t.text :message, null: false     # Message should also be required
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
