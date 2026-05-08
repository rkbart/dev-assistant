class VectorSearchService
  def self.search(query, limit: 5)
    query_embedding = EmbeddingService.embed(query)

    scored_chunks = CodeChunk.all.map do |chunk|
      score = SimilarityService.cosine_similarity(
        query_embedding,
        chunk.embedding
      )

      {
        chunk: chunk,
        score: score
      }
    end

    scored_chunks
      .sort_by { |r| -r[:score] }
      .first(limit)
  end
end
