require "net/http"
require "uri"
require "json"

class LlmService
  OLLAMA_URL = URI("http://localhost:11434/api/generate")

  def self.ask(prompt)
    http = Net::HTTP.new(OLLAMA_URL.host, OLLAMA_URL.port)
    http.read_timeout = 120
    http.open_timeout = 10
    
    request = Net::HTTP::Post.new(OLLAMA_URL)
    request["Content-Type"] = "application/json"

    request.body = {
      model: "phi3",  # Faster model than mistral
      prompt: prompt,
      stream: false,
      options: {
        num_predict: 500  # Limit output tokens
      }
    }.to_json

    response = http.request(request)
    JSON.parse(response.body)
  end
end
