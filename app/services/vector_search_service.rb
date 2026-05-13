class VectorSearchService
  CANDIDATE_LIMIT = 50
  EMBEDDING_WEIGHT = 0.8
  KEYWORD_WEIGHT = 0.15
  SYMBOL_WEIGHT = 0.1

  FILE_PENALTIES = {
    "seeds.rb" => -0.3,
    "spec/" => -0.25,
    "test/" => -0.25,
    "fixtures/" => -0.2,
    "node_modules" => -1.0,
    "dist" => -0.5,
    "build" => -0.5
  }

  def self.search(query, limit: 5, project_id: nil, language: nil)
    query_embedding = EmbeddingService.embed(query)
    candidates = fetch_candidates(query, project_id, language)

    scored = candidates.map do |chunk|
      similarity = SimilarityService.cosine_similarity(
        query_embedding,
        chunk.embedding
      )

      keyword_score = keyword_boost(query, chunk.content)
      symbol_score = symbol_boost(query, chunk.symbol_name)
      file_penalty = file_penalty(chunk.file_path)
      project_boost = project_relevance_boost(query, chunk.project)

      final_score =
        (similarity * EMBEDDING_WEIGHT) +
        (keyword_score * KEYWORD_WEIGHT) +
        (symbol_score * SYMBOL_WEIGHT) +
        project_boost +
        file_penalty

      {
        chunk: chunk,
        score: final_score,
        similarity: similarity,
        keyword_score: keyword_score,
        symbol_score: symbol_score,
        project_boost: project_boost
      }
    end

    scored
      .sort_by { |r| -r[:score] }
      .first(limit)
  end

  def self.fetch_candidates(query, project_id = nil, language = nil)
    scope = CodeChunk.includes(:project)

    # Apply explicit filters
    scope = scope.where(project_id: project_id) if project_id
    scope = scope.where(language: language) if language

    # intent-based filtering (light but useful)
    if query.match?(/react|frontend|component/i)
      scope = scope.where(language: ["javascript", "typescript"])
    elsif query.match?(/rails|backend|controller|model|api/i)
      scope = scope.where(language: "ruby")
    end

    scope = scope.where.not("file_path LIKE ?", "%node_modules%")
    scope = scope.where.not("file_path LIKE ?", "%dist%")
    scope = scope.where.not("file_path LIKE ?", "%build%")

    scope
      .select(
        :id, :file_path, :content, :embedding,
        :symbol_name, :chunk_type, :start_line, :end_line, :language,
        :project_id
      )
      .limit(CANDIDATE_LIMIT)
  end

  # -----------------------------
  # Scoring helpers
  # -----------------------------

  def self.keyword_boost(query, content)
    words = query.downcase.scan(/\w+/)
    return 0.0 if words.empty?

    matches = words.count do |word|
      exact_code_match?(word, content)
    end

    matches.to_f / words.size
  end

  def self.symbol_boost(query, symbol_name)
    return 0.0 if symbol_name.nil?

    query_words = query.downcase.scan(/\w+/)
    symbol = symbol_name.downcase

    query_words.any? { |w| symbol.include?(w) } ? 1.0 : 0.0
  end

  def self.file_penalty(file_path)
    FILE_PENALTIES.each do |pattern, penalty|
      return penalty if file_path.include?(pattern)
    end
    0.0
  end

  def self.project_relevance_boost(query, project)
    return 0.0 unless project
    
    boost = 0.0
    
    # Boost if project name matches query
    if query.downcase.include?(project.name.downcase)
      boost += 0.2
    end
    
    # Boost if tech stack matches query keywords
    if project.tech_stack
      tech_keywords = project.tech_stack.downcase.split(/[\s,]+/)
      query_words = query.downcase.scan(/\w+/)
      
      matching_keywords = tech_keywords & query_words
      boost += (matching_keywords.length * 0.1)
    end
    
    # Boost recently indexed projects
    if project.last_indexed_at && project.last_indexed_at > 1.week.ago
      boost += 0.05
    end
    
    boost
  end

  def self.exact_code_match?(word, content)
    patterns = [
      "\\.#{word}\\b",
      "\\b#{word}\\(",
      "\\b#{word}\\b"
    ]

    patterns.any? { |p| Regexp.new(p).match?(content) }
  end

  # -----------------------------
  # Debug helper
  # -----------------------------
  def self.debug(results)
    results.each_with_index do |r, i|
      puts "\n=== RESULT #{i + 1} ==="
      puts "Score: #{r[:score].round(4)}"
      puts "Sim: #{r[:similarity].round(4)}"
      puts "Keyword: #{r[:keyword_score].round(4)}"
      puts "Symbol: #{r[:symbol_score].round(4)}"
      puts "File: #{r[:chunk].file_path}"
      puts "Symbol: #{r[:chunk].symbol_name}"
    end
  end

  def self.inspect_first(query)
    results = search(query)

    results.each do |r|
      chunk = r[:chunk]

      similarity = r[:similarity]
      keyword = r[:keyword_score]
      symbol = r[:symbol_score]
      penalty = file_penalty(chunk.file_path)

      puts "\n--- #{chunk.symbol_name} ---"
      puts "Sim: #{similarity.round(4)}"
      puts "Keyword: #{keyword.round(4)}"
      puts "Symbol: #{symbol.round(4)}"
      puts "Penalty: #{penalty}"
      puts "FINAL: #{r[:score].round(4)}"
    end

    nil
  end
end