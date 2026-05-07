class CreateCodeChunks < ActiveRecord::Migration[8.1]
  def change
    create_table :code_chunks do |t|
      t.text :content
      t.string :file_path
      t.jsonb :embedding

      t.timestamps
    end
  end
end
