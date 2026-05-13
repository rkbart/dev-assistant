require "digest"

class RepoIndexer
  SUPPORTED_EXTENSIONS = %w[
    .rb
    .js
    .ts
    .jsx
    .tsx
    .md
    .txt
    .yml
    .yaml
    .json
  ]

  IGNORE_PATTERNS = %w[
    node_modules
    tmp
    log
    coverage
    dist
    build
    .git
    vendor
    storage
    .DS_Store
  ]

  BATCH_SIZE = 20

  def self.index(root_path)
    project = Project.index_project(root_path)
    index_project(project)
  end

  def self.index_project(project)
    files = discover_files(project.path)

    puts "\n� Starting indexing for project '#{project.name}' (#{files.size} files)..."

    # Clear existing chunks for this project
    project.code_chunks.delete_all

    files.each_slice(BATCH_SIZE).with_index do |batch, batch_index|
      puts "\n🚀 Processing batch #{batch_index + 1}"

      batch.each do |file|
        process_file(file, project)
      end
    end

    project.update!(last_indexed_at: Time.current)
    puts "\n🎉 Indexing complete for '#{project.name}'!"
  end

  def self.process_file(file_path, project)
    puts "\n➡️ Processing: #{file_path}"

    content = File.read(file_path)

    file_hash = Digest::SHA256.hexdigest(content)

    if already_indexed?(file_path, file_hash, project)
      puts "⏭️ Skipping unchanged file"
      return
    end

    # Remove existing chunks for this file in this project
    project.code_chunks.where(file_path: file_path).delete_all

    chunks = CodeChunker.chunk(file_path)

    puts "   ↳ #{chunks.size} semantic chunks"

    embeddings = EmbeddingService.embed_batch(
      chunks.map { |c| c[:content] }
    )

    records = chunks.each_with_index.map do |chunk, index|
      {
        content: chunk[:content],
        file_path: chunk[:file_path],
        language: chunk[:language],
        chunk_type: chunk[:chunk_type],
        symbol_name: chunk[:symbol_name],
        start_line: chunk[:start_line],
        end_line: chunk[:end_line],
        file_hash: file_hash,
        project_id: project.id,
        embedding: embeddings[index],
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    CodeChunk.insert_all(records)

    puts "   ✅ Saved #{records.size} chunks"
  rescue => e
    puts "   ❌ ERROR: #{e.message}"
  end

  def self.already_indexed?(file_path, file_hash, project)
    project.code_chunks.exists?(
      file_path: file_path,
      file_hash: file_hash
    )
  end

  def self.discover_files(path)
    Dir.glob("#{path}/**/*")
       .select { |f| File.file?(f) }
       .select { |f| SUPPORTED_EXTENSIONS.include?(File.extname(f)) }
       .reject do |f|
          IGNORE_PATTERNS.any? { |pattern| f.include?(pattern) }
       end
  end
end