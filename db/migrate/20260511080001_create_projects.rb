class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :path, null: false
      t.text :description
      t.text :tech_stack
      t.datetime :last_indexed_at

      t.timestamps
    end

    add_index :projects, :name, unique: true
    add_index :projects, :path, unique: true
  end
end
