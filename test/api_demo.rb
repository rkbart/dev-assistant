#!/usr/bin/env ruby

# Demo script to test the API endpoints
require 'net/http'
require 'json'
require 'uri'

class ApiDemo
  BASE_URL = 'http://localhost:3000/api/v1'
  
  def initialize
    @http = Net::HTTP.new('localhost', 3000)
  end
  
  def run_demo
    puts "🚀 Dev Assistant API Demo"
    puts "=" * 50
    
    # 1. List projects
    list_projects
    
    # 2. Test different types of queries
    test_queries = [
      "Which project used RAG?",
      "What does .map do?",
      "When was my last project with OAuth?",
      "Show me React components",
      "How to implement authentication in Rails?"
    ]
    
    test_queries.each { |query| test_query(query) }
    
    puts "\n✅ Demo complete!"
  end
  
  def list_projects
    puts "\n📚 Listing projects..."
    response = make_request('/projects')
    
    if response['projects']
      puts "Found #{response['projects'].length} projects:"
      response['projects'].each do |project|
        puts "  - #{project['name']}: #{project['chunk_count']} chunks"
        puts "    Tech: #{project['tech_stack']}"
        puts "    Created: #{project['created_at']}"
        puts
      end
    else
      puts "No projects found. Run demo_setup.rb first!"
    end
  end
  
  def test_query(query)
    puts "\n❓ Query: #{query}"
    puts "-" * 30
    
    response = make_request('/ask', { prompt: query })
    
    if response['answer']
      puts "📝 Answer:"
      puts response['answer']
      
      if response['sources'] && !response['sources'].empty?
        puts "\n📚 Sources:"
        response['sources'].each do |source|
          puts "  - #{source['project']}: #{source['file']}:#{source['lines']} (relevance: #{source['relevance']})"
        end
      end
      
      if response['projects'] && !response['projects'].empty?
        puts "\n🏗️  Projects referenced:"
        response['projects'].each do |project|
          puts "  - #{project['name']}: #{project['tech_stack']}"
        end
      end
    else
      puts "❌ No answer received"
    end
    
    puts "\n" + "=" * 50
  end
  
  private
  
  def make_request(endpoint, params = {})
    uri = URI("#{BASE_URL}#{endpoint}")
    
    if params.empty?
      request = Net::HTTP::Get.new(uri)
    else
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = params.to_json
    end
    
    response = @http.request(request)
    JSON.parse(response.body)
  rescue => e
    puts "❌ Error: #{e.message}"
    {}
  end
end

# Check if server is running, then run demo
begin
  Net::HTTP.get('localhost', '/api/v1/projects', 3000)
  ApiDemo.new.run_demo
rescue => e
  puts "❌ Server not running on localhost:3000"
  puts "Please start the Rails server first:"
  puts "  rails server"
  puts ""
  puts "And make sure you've run the demo setup:"
  puts "  ruby test/demo_setup.rb"
end
