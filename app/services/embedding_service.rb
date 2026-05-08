require "net/http"
require "json"

class EmbeddingService
  URL = URI("http://localhost:11434/api/embeddings")

  def self.embed(text)
    request_embedding(text)
  end

  def self.embed_batch(texts)
    texts.map { |t| request_embedding(t) }
  end

  def self.request_embedding(text)
    http = Net::HTTP.new(URL.host, URL.port)

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
