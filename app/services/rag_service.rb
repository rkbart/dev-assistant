class RagService
  MAX_CONTEXT_CHUNKS = 4
  MAX_TOKENS_PER_CHUNK = 300
  
  def self.answer(query)
    # Step 1: Retrieve relevant chunks
    relevant_chunks = retrieve_relevant_chunks(query)
    
    # Step 2: Build context with project information
    context = build_context(relevant_chunks, query)
    
    # Step 3: Generate answer using LLM with context
    answer = generate_answer(query, context)
    
    # Step 4: Return structured response
    {
      query: query,
      answer: answer,
      sources: format_sources(relevant_chunks),
      projects: extract_projects(relevant_chunks)
    }
  end
  
  private
  
  def self.retrieve_relevant_chunks(query)
    # Use enhanced vector search with project awareness
    VectorSearchService.search(query, limit: MAX_CONTEXT_CHUNKS)
  end
  
  def self.build_context(chunks, query)
    return "No relevant information found." if chunks.empty?
    
    # Group chunks by project for better context
    grouped_chunks = chunks.group_by { |c| c[:chunk].project }
    
    context_parts = []
    
    grouped_chunks.each do |project, project_chunks|
      context_parts << "## #{project.name}"
      context_parts << "Stack: #{project.tech_stack || 'Unknown'}"
      context_parts << ""
      
      project_chunks.first(2).each_with_index do |chunk_result, i|
        chunk = chunk_result[:chunk]
        context_parts << "### #{chunk.symbol_name || 'Unknown'}"
        context_parts << "#{chunk.file_path}:#{chunk.start_line}"
        context_parts << "```#{chunk.language}"
        context_parts << truncate_content(chunk.content)
        context_parts << "```"
        context_parts << ""
      end
    end
    
    context_parts.join("\n")
  end
  
  def self.generate_answer(query, context)
    prompt = build_prompt(query, context)
    
    response = LlmService.ask(prompt)
    response["response"]
  end
  
  def self.build_prompt(query, context)
    <<~PROMPT
      Context: #{context}
      
      Question: #{query}
      
      Answer concisely based on the context. Reference specific files and code.
    PROMPT
  end
  
  def self.format_sources(chunks)
    chunks.map do |chunk_result|
      chunk = chunk_result[:chunk]
      {
        project: chunk.project.name,
        file: chunk.file_path,
        lines: "#{chunk.start_line}-#{chunk.end_line}",
        symbol: chunk.symbol_name,
        relevance: chunk_result[:score].round(3)
      }
    end
  end
  
  def self.extract_projects(chunks)
    chunks.map { |c| c[:chunk].project }
           .uniq
           .map { |p| { name: p.name, tech_stack: p.tech_stack, description: p.description } }
  end
  
  def self.truncate_content(content)
    # Truncate to prevent token overflow
    lines = content.lines
    if lines.length > 20
      lines.first(20).join + "\n... (truncated)"
    else
      content
    end
  end
  
  # Specialized query handlers
  
  def self.answer_which_project(query, technology)
    projects = Project.where("tech_stack ILIKE ?", "%#{technology}%")
                    .or(Project.where("description ILIKE ?", "%#{technology}%"))
    
    if projects.any?
      {
        answer: "Found #{projects.count} project(s) using #{technology}: #{projects.map(&:name).join(', ')}",
        projects: projects.map { |p| { name: p.name, tech_stack: p.tech_stack } }
      }
    else
      {
        answer: "No projects found using #{technology}",
        projects: []
      }
    end
  end
  
  def self.answer_last_project_with(technology)
    projects = Project.where("tech_stack ILIKE ?", "%#{technology}%")
                    .order(created_at: :desc)
                    .limit(5)
    
    if projects.any?
      latest = projects.first
      {
        answer: "Your most recent project using #{technology} is '#{latest.name}' (created #{latest.created_at.strftime('%B %d, %Y')})",
        projects: projects.map { |p| { name: p.name, created_at: p.created_at } }
      }
    else
      {
        answer: "No projects found using #{technology}",
        projects: []
      }
    end
  end
end
