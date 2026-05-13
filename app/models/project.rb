class Project < ApplicationRecord
  has_many :code_chunks, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :path, presence: true, uniqueness: true
  
  def self.index_project(path)
    project_name = File.basename(path)
    
    project = find_or_initialize_by(path: path) do |p|
      p.name = project_name
      p.description = extract_description(path)
      p.tech_stack = detect_tech_stack(path)
      p.created_at = detect_project_creation(path)
    end
    
    project.save!
    project
  end
  
  def reindex!
    RepoIndexer.index_project(self)
    update!(last_indexed_at: Time.current)
  end
  
  private
  
  def self.extract_description(path)
    readme_path = Dir.glob("#{path}/README*").first
    return nil unless readme_path && File.exist?(readme_path)
    
    content = File.read(readme_path)
    content.lines.first(3).join.strip
  end
  
  def self.detect_tech_stack(path)
    tech_stack = []
    
    # Check for common tech indicators
    tech_stack << "Ruby on Rails" if File.exist?("#{path}/Gemfile")
    tech_stack << "Node.js" if File.exist?("#{path}/package.json")
    tech_stack << "React" if File.exist?("#{path}/package.json") && File.read("#{path}/package.json").include?("react")
    tech_stack << "TypeScript" if Dir.glob("#{path}/**/*.ts").any?
    tech_stack << "Python" if Dir.glob("#{path}**/requirements.txt").any? || Dir.glob("#{path}**/pyproject.toml").any?
    
    tech_stack.join(", ")
  end
  
  def self.detect_project_creation(path)
    git_path = "#{path}/.git"
    return Time.current unless File.directory?(git_path)
    
    begin
      # Get first commit date
      output = `cd #{path} && git log --reverse --format="%ct" | head -1`
      Time.at(output.to_i) if output.strip.present?
    rescue
      Time.current
    end
  end
end
