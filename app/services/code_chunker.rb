class CodeChunker
  SUPPORTED_EXTENSIONS = {
    ".rb" => "ruby",
    ".js" => "javascript",
    ".ts" => "typescript",
    ".jsx" => "javascript",
    ".tsx" => "typescript",
    ".md" => "markdown",
    ".txt" => "text",
    ".yml" => "yaml",
    ".yaml" => "yaml",
    ".json" => "json"
  }

  RUBY_PATTERN = /
    (
      class\s+\w+.*?end
      |
      module\s+\w+.*?end
      |
      def\s+\w+.*?end
    )
  /mx

  JS_PATTERN = /
    (
      export\s+default\s+function\s+\w+.*?\}
      |
      export\s+function\s+\w+.*?\}
      |
      function\s+\w+.*?\}
      |
      const\s+\w+\s*=\s*\(?.*?=>\s*\{
        .*?
      \}
      |
      class\s+\w+.*?\}
    )
  /mx

  MARKDOWN_PATTERN = %r{
    (
      ^\#{1,6}\s+.+$
      |
      ^[\w\s]+$
    )
  }mx

  def self.chunk(file_path)
    extension = File.extname(file_path)

    language = SUPPORTED_EXTENSIONS[extension]

    return [] unless language

    content = File.read(file_path)

    chunks =
      case language
      when "ruby"
        extract_chunks(content, RUBY_PATTERN, file_path, language)
      when "javascript", "typescript"
        extract_chunks(content, JS_PATTERN, file_path, language)
      when "markdown"
        extract_chunks(content, MARKDOWN_PATTERN, file_path, language)
      when "yaml", "json", "text"
        fallback_chunk(content, file_path, language)
      else
        []
      end

    chunks.empty? ? fallback_chunk(content, file_path, language) : chunks
  end

  def self.extract_chunks(content, pattern, file_path, language)
    chunks = []

    content.to_enum(:scan, pattern).each do
      match = Regexp.last_match

      chunk_content = match[0]

      start_offset = match.begin(0)
      end_offset = match.end(0)

      start_line = content[0...start_offset].count("\n") + 1
      end_line = content[0...end_offset].count("\n") + 1

      chunks << {
        content: chunk_content.strip,
        file_path: file_path,
        language: language,
        chunk_type: detect_chunk_type(chunk_content, language),
        symbol_name: extract_symbol_name(chunk_content, language),
        start_line: start_line,
        end_line: end_line
      }
    end

    chunks
  end

  def self.detect_chunk_type(content, language)
    case language
    when "ruby"
      return "class" if content.match?(/class\s+\w+/)
      return "module" if content.match?(/module\s+\w+/)
      return "method" if content.match?(/def\s+\w+/)
    when "javascript", "typescript"
      return "component" if content.match?(/export\s+default\s+function/)
      return "function" if content.match?(/function\s+\w+/)
      return "arrow_function" if content.match?(/const\s+\w+\s*=\s*\(?.*?=>/)
      return "class" if content.match?(/class\s+\w+/)
    when "markdown"
      return "heading" if content.match?(/^\#\{1,6\}\s+/)
      return "section" if content.match?(/\n\n/)
      return "document"
    when "yaml", "json"
      return "configuration"
    when "text"
      return "document"
    end

    "unknown"
  end

  def self.extract_symbol_name(content, language)
    patterns = [
      /class\s+(\w+)/,
      /module\s+(\w+)/,
      /def\s+(\w+)/,
      /function\s+(\w+)/,
      /const\s+(\w+)/,
      /export\s+default\s+function\s+(\w+)/
    ]

    patterns.each do |pattern|
      match = content.match(pattern)
      return match[1] if match
    end

    nil
  end

  def self.fallback_chunk(content, file_path, language)
    [{
      content: content,
      file_path: file_path,
      language: language,
      chunk_type: "file",
      symbol_name: File.basename(file_path),
      start_line: 1,
      end_line: content.lines.count
    }]
  end
end