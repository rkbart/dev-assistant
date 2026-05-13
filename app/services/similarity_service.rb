class SimilarityService
  def self.cosine_similarity(vec1, vec2)
    return 0 if vec1.nil? || vec2.nil?
    
    dot_product = vec1.zip(vec2).sum { |a, b| a * b }

    magnitude1 = Math.sqrt(vec1.sum { |x| x**2 })
    magnitude2 = Math.sqrt(vec2.sum { |x| x**2 })

    return 0 if magnitude1.zero? || magnitude2.zero?

    dot_product / (magnitude1 * magnitude2)
  end
end
