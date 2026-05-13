#!/usr/bin/env ruby

# Demo script to set up test projects and demonstrate the RAG system
require_relative '../config/environment'

puts "🚀 Setting up demo data for Dev Assistant API..."

# Helper methods for creating demo files
def create_rails_blog_files(path)
  # Gemfile
  File.write("#{path}/Gemfile", <<~RUBY)
    source "https://rubygems.org"
    gem "rails", "~> 7.0"
    gem "pg"
    gem "devise"
  RUBY
  
  # Controller
  FileUtils.mkdir_p("#{path}/app/controllers")
  File.write("#{path}/app/controllers/posts_controller.rb", <<~RUBY)
    class PostsController < ApplicationController
      before_action :authenticate_user!
      
      def index
        @posts = Post.all
        render json: @posts.map { |post| post.as_json(include: :comments) }
      end
      
      def create
        @post = current_user.posts.create(post_params)
        if @post.persisted?
          render json: @post, status: :created
        else
          render json: { errors: @post.errors }, status: :unprocessable_entity
        end
      end
      
      private
      
      def post_params
        params.require(:post).permit(:title, :content)
      end
    end
  RUBY
  
  # Model
  FileUtils.mkdir_p("#{path}/app/models")
  File.write("#{path}/app/models/post.rb", <<~RUBY)
    class Post < ApplicationRecord
      belongs_to :user
      has_many :comments, dependent: :destroy
      
      validates :title, presence: true, length: { minimum: 3 }
      validates :content, presence: true
      
      scope :published, -> { where(published: true) }
      scope :recent, -> { order(created_at: :desc) }
      
      def excerpt(length: 100)
        content.truncate(length)
      end
    end
  RUBY
  
  # README
  File.write("#{path}/README.md", <<~MARKDOWN)
    # Blog Rails Application
    
    A simple blog application built with Ruby on Rails 7.0.
    
    ## Features
    - User authentication with Devise
    - CRUD operations for posts and comments
    - PostgreSQL database
    - RESTful API endpoints
    
    ## Setup
    \`\`\`bash
    bundle install
    rails db:migrate
    rails server
    \`\`\`
    
    ## API Endpoints
    - GET /posts - List all posts
    - POST /posts - Create new post
    - GET /posts/:id - Show specific post
  MARKDOWN
end

def create_react_todo_files(path)
  # package.json
  File.write("#{path}/package.json", <<~JSON)
    {
      "name": "react-todo",
      "version": "1.0.0",
      "dependencies": {
        "react": "^18.0.0",
        "typescript": "^4.9.0",
        "@types/react": "^18.0.0"
      },
      "scripts": {
        "start": "react-scripts start",
        "build": "react-scripts build"
      }
    }
  JSON
  
  # React Component
  FileUtils.mkdir_p("#{path}/src/components")
  File.write("#{path}/src/components/TodoList.tsx", <<~TYPESCRIPT)
    import React, { useState, useEffect } from 'react';
    
    interface Todo {
      id: number;
      text: string;
      completed: boolean;
    }
    
    export const TodoList: React.FC = () => {
      const [todos, setTodos] = useState<Todo[]>([]);
      const [inputValue, setInputValue] = useState('');
      
      useEffect(() => {
        const savedTodos = localStorage.getItem('todos');
        if (savedTodos) {
          setTodos(JSON.parse(savedTodos));
        }
      }, []);
      
      const addTodo = () => {
        if (inputValue.trim()) {
          const newTodo: Todo = {
            id: Date.now(),
            text: inputValue,
            completed: false
          };
          setTodos([...todos, newTodo]);
          setInputValue('');
          saveTodos([...todos, newTodo]);
        }
      };
      
      const toggleTodo = (id: number) => {
        const updatedTodos = todos.map(todo =>
          todo.id === id ? { ...todo, completed: !todo.completed } : todo
        );
        setTodos(updatedTodos);
        saveTodos(updatedTodos);
      };
      
      const saveTodos = (todosToSave: Todo[]) => {
        localStorage.setItem('todos', JSON.stringify(todosToSave));
      };
      
      return (
        <div className="todo-list">
          <h2>Todo List</h2>
          <div className="input-section">
            <input
              type="text"
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && addTodo()}
              placeholder="Add a new todo..."
            />
            <button onClick={addTodo}>Add</button>
          </div>
          <ul>
            {todos.map(todo => (
              <li key={todo.id}>
                <input
                  type="checkbox"
                  checked={todo.completed}
                  onChange={() => toggleTodo(todo.id)}
                />
                <span className={todo.completed ? 'completed' : ''}>
                  {todo.text}
                </span>
              </li>
            ))}
          </ul>
        </div>
      );
    };
  TYPESCRIPT
  
  # README
  File.write("#{path}/README.md", <<~MARKDOWN)
    # React Todo App
    
    A modern todo application built with React and TypeScript.
    
    ## Features
    - TypeScript for type safety
    - Local storage persistence
    - Component-based architecture
    - Modern React hooks
    
    ## Components
    - \`TodoList\`: Main component managing todo state
    - Uses \`useState\` and \`useEffect\` hooks
    - Implements CRUD operations for todos
    
    ## Usage
    \`\`\`bash
    npm install
    npm start
    \`\`\`
  MARKDOWN
end

def create_oauth_service_files(path)
  # Gemfile
  File.write("#{path}/Gemfile", <<~RUBY)
    source "https://rubygems.org"
    gem "rails", "~> 7.0"
    gem "oauth2"
    gem "jwt"
    gem "doorkeeper"
  RUBY
  
  # OAuth Controller
  FileUtils.mkdir_p("#{path}/app/controllers")
  File.write("#{path}/app/controllers/oauth_controller.rb", <<~RUBY)
    class OauthController < ApplicationController
      def authorize
        client = OAuth2::Client.new(
          ENV['OAUTH_CLIENT_ID'],
          ENV['OAUTH_CLIENT_SECRET'],
          site: ENV['OAUTH_PROVIDER_URL']
        )
        
        redirect_to client.auth_code.authorize_url(
          redirect_uri: oauth_callback_url,
          scope: 'read write'
        )
      end
      
      def callback
        client = OAuth2::Client.new(
          ENV['OAUTH_CLIENT_ID'],
          ENV['OAUTH_CLIENT_SECRET'],
          site: ENV['OAUTH_PROVIDER_URL']
        )
        
        token = client.auth_code.get_token(
          params[:code],
          redirect_uri: oauth_callback_url
        )
        
        user_info = token.get('/api/user').parsed
        user = find_or_create_user(user_info)
        
        render json: { 
          token: generate_jwt(user),
          user: user.as_json(only: [:id, :email, :name])
        }
      end
      
      private
      
      def find_or_create_user(user_info)
        User.find_or_create_by(
          provider: params[:provider],
          uid: user_info['id']
        ) do |user|
          user.email = user_info['email']
          user.name = user_info['name']
        end
      end
      
      def generate_jwt(user)
        JWT.encode(
          { user_id: user.id, exp: 24.hours.from_now.to_i },
          Rails.application.secret_key_base
        )
      end
    end
  RUBY
  
  # README
  File.write("#{path}/README.md", <<~MARKDOWN)
    # OAuth Authentication Service
    
    Rails service implementing OAuth 2.0 authentication with JWT tokens.
    
    ## Features
    - OAuth 2.0 integration
    - JWT token generation
    - Multi-provider support
    - Secure authentication flow
    
    ## OAuth Flow
    1. User clicks "Login with Provider"
    2. Redirect to OAuth provider
    3. Provider redirects back with authorization code
    4. Exchange code for access token
    5. Generate JWT for API access
    
    ## Configuration
    Set these environment variables:
    - \`OAUTH_CLIENT_ID\`
    - \`OAUTH_CLIENT_SECRET\`
    - \`OAUTH_PROVIDER_URL\`
  MARKDOWN
end

# Create demo project directories
demo_projects = [
  {
    name: "blog_rails",
    path: "/tmp/demo_projects/blog_rails",
    tech_stack: "Ruby on Rails, PostgreSQL, Bootstrap",
    description: "A simple blog application built with Rails"
  },
  {
    name: "react_todo",
    path: "/tmp/demo_projects/react_todo", 
    tech_stack: "React, TypeScript, Node.js",
    description: "A modern todo app built with React and TypeScript"
  },
  {
    name: "oauth_service",
    path: "/tmp/demo_projects/oauth_service",
    tech_stack: "Ruby on Rails, OAuth, JWT",
    description: "Authentication service with OAuth integration"
  }
]

# Create demo project directories and files
demo_projects.each do |project_config|
  path = project_config[:path]
  FileUtils.mkdir_p(path)
  
  puts "📁 Creating #{project_config[:name]} at #{path}"
  
  case project_config[:name]
  when "blog_rails"
    create_rails_blog_files(path)
  when "react_todo"
    create_react_todo_files(path)
  when "oauth_service"
    create_oauth_service_files(path)
  end
end

# Index the projects
demo_projects.each do |project_config|
  puts "\n📚 Indexing #{project_config[:name]}..."
  project = Project.index_project(project_config[:path])
  project.update!(
    description: project_config[:description],
    tech_stack: project_config[:tech_stack],
    created_at: rand(1..12).months.ago
  )
  project.reindex!
end

puts "\n✅ Demo setup complete!"
puts "\n📊 Projects created:"
Project.all.each do |project|
  puts "  - #{project.name}: #{project.code_chunks.count} chunks"
end

puts "\n🧪 Testing queries..."
test_queries = [
  "Which project used RAG?",
  "What does .map do?", 
  "When was my last project with OAuth?",
  "Show me React components",
  "How to implement authentication in Rails?"
]

test_queries.each do |query|
  puts "\n❓ Query: #{query}"
  result = RagService.answer(query)
  puts "📝 Answer: #{result[:answer][0..200]}..."
  puts "📚 Sources: #{result[:sources].count} found"
end

puts "\n🎉 Demo complete! You can now test the API endpoints."
