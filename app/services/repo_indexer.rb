class RepoIndexer
  def self.index(root_path)
    files = discover_files(root_path)

    puts "📦 Found #{files.size} files"

    files.each_with_index do |file, index|
      puts "➡️ Processing (#{index + 1}/#{files.size}): #{file}"

      chunks = CodeChunker.chunk(file)
      puts "   ↳ #{chunks.size} chunks"

      embeddings = EmbeddingService.embed_batch(
        chunks.map { |c| c[:content] }
      )

      chunks.each_with_index do |chunk, i|
        CodeChunk.create!(
          content: chunk[:content],
          file_path: chunk[:file_path],
          embedding: embeddings[i]
        )
      end

      puts "   ✅ Saved #{chunks.size} chunks"
    end

    puts "🎉 Indexing complete!"
  end

  def self.discover_files(path)
    Dir.glob("#{path}/**/*.{rb,js,ts,jsx,tsx}")
       .reject { |f| f.include?("node_modules") || f.include?("log") }
  end
end
