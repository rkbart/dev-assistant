require "net/http"
require "json"

class EmbeddingService
  URL = URI("http://localhost:11434/api/embeddings")
  CACHE = {}
  CACHE_TTL = 3600 # 1 hour

  def self.embed(text)
    cache_key = text.downcase.strip
    cached = CACHE[cache_key]
    
    if cached && cached[:timestamp] > Time.now.to_i - CACHE_TTL
      return cached[:embedding]
    end
    
    embedding = request_embedding(text)
    CACHE[cache_key] = { embedding: embedding, timestamp: Time.now.to_i }
    embedding
  end

  def self.embed_batch(texts)
    texts.map { |t| embed(t) }
  end

  def self.request_embedding(text)
    http = Net::HTTP.new(URL.host, URL.port)
    http.read_timeout = 30
    http.open_timeout = 10

    req = Net::HTTP::Post.new(URL)
    req["Content-Type"] = "application/json"

    req.body = {
      model: "nomic-embed-text",
      prompt: text
    }.to_json

    res = http.request(req)
    JSON.parse(res.body)["embedding"]
  end
end
