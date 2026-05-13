class CodeChunk < ApplicationRecord
  belongs_to :project
  
  validates :content, presence: true
  validates :file_path, presence: true
  validates :language, presence: true
  
  scope :by_language, ->(language) { where(language: language) }
  scope :by_chunk_type, ->(chunk_type) { where(chunk_type: chunk_type) }
  scope :recent, -> { order(created_at: :desc) }
  
  def self.search_within_project(project_id, query)
    where(project_id: project_id).ransack(content_cont: query).result
  end
end
