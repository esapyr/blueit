class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.string :did
      t.string :rkey
      t.string :text
      t.boolean :root, default: true
      t.timestamps
    end

    add_index :comments, :rkey
  end
end
