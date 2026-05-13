class Api::V1::AiController < ApplicationController
  def ask
    query = params[:prompt]
    
    # Handle specialized queries
    if query.match?(/which project.*used/i)
      technology = extract_technology(query)
      result = RagService.answer_which_project(query, technology)
    elsif query.match?(/when.*last.*project.*with/i) || query.match?(/last.*project.*with/i)
      technology = extract_technology(query)
      result = RagService.answer_last_project_with(technology)
    else
      # Use general RAG pipeline
      result = RagService.answer(query)
    end

    render json: result
  end
  
  def projects
    projects = Project.all.order(created_at: :desc)
    render json: projects.map { |p| 
      {
        id: p.id,
        name: p.name,
        description: p.description,
        tech_stack: p.tech_stack,
        created_at: p.created_at,
        last_indexed_at: p.last_indexed_at,
        chunk_count: p.code_chunks.count
      }
    }
  end
  
  def index_project
    project_path = params[:path]
    
    if project_path.blank?
      render json: { error: "Project path is required" }, status: :unprocessable_entity
      return
    end
    
    unless Dir.exist?(project_path)
      render json: { error: "Project path does not exist" }, status: :not_found
      return
    end
    
    project = Project.index_project(project_path)
    project.reindex!
    
    render json: { 
      message: "Project '#{project.name}' indexed successfully",
      project: {
        id: project.id,
        name: project.name,
        path: project.path,
        tech_stack: project.tech_stack,
        chunk_count: project.code_chunks.count
      }
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
  
  private
  
  def extract_technology(query)
    # Extract technology names from queries like "which project used RAG" or "last project with OAuth"
    technologies = %w[RAG OAuth React Ruby Rails Node.js TypeScript JavaScript Python Django Flask Express]
    technologies.find { |tech| query.downcase.include?(tech.downcase) }
  end
end
