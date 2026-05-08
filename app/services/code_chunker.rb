class CodeChunker
  MAX_LINES = 200

  def self.chunk(file_path)
    lines = File.readlines(file_path)
    chunks = []

    lines.each_slice(MAX_LINES) do |slice|
      next if slice.join.strip.empty?

      chunks << {
        content: slice.join,
        file_path: file_path
      }
    end

    chunks
  end
end
