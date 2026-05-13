class AddMetadataToCodeChunks < ActiveRecord::Migration[8.1]
  def change
    add_column :code_chunks, :language, :string
    add_column :code_chunks, :chunk_type, :string
    add_column :code_chunks, :symbol_name, :string
    add_column :code_chunks, :start_line, :integer
    add_column :code_chunks, :end_line, :integer
    add_column :code_chunks, :file_hash, :string

    add_index :code_chunks, :language
    add_index :code_chunks, :chunk_type
    add_index :code_chunks, :symbol_name
    add_index :code_chunks, :file_hash
  end
end