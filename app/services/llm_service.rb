require "net/http"
require "uri"
require "json"

class LlmService
  OLLAMA_URL = URI("http://localhost:11434/api/generate")

  def self.ask(prompt)
    http = Net::HTTP.new(OLLAMA_URL.host, OLLAMA_URL.port)
    request = Net::HTTP::Post.new(OLLAMA_URL)
    request["Content-Type"] = "application/json"

    request.body = {
      model: "mistral",
      prompt: prompt,
      stream: false
    }.to_json

    response = http.request(request)
    JSON.parse(response.body)
  end
end
