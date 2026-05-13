# 🧪 Testing Guide - Dev Assistant API RAG System

Your multi-project RAG system is now fully implemented and ready for testing!

## ✅ What's Been Completed

### Database Setup
- ✅ Projects table created with metadata support
- ✅ CodeChunks table updated with project relationships
- ✅ All existing chunks migrated to "Legacy Code" project
- ✅ Proper indexes and constraints added

### Core Services
- ✅ **Project Model**: Multi-project support with tech stack detection
- ✅ **Enhanced CodeChunker**: Processes code + documentation files
- ✅ **RagService**: Context-aware Q&A pipeline
- ✅ **VectorSearchService**: Project-aware hybrid search
- ✅ **AiController**: RAG-powered API endpoints

### Demo Data
- ✅ **blog_rails**: Ruby on Rails blog app
- ✅ **react_todo**: React TypeScript todo app
- ✅ **oauth_service**: Rails OAuth authentication service

## 🚀 How to Test

### Step 1: Install Dependencies
```bash
bundle install
```

### Step 2: Start Ollama (Local AI)
```bash
# Terminal 1
ollama serve

# Terminal 2 (after Ollama starts)
ollama pull mistral
ollama pull nomic-embed-text
```

### Step 3: Start Rails Server
```bash
# Terminal 3
rails server
```

### Step 4: Index Demo Projects
```bash
# Terminal 4
curl -X POST http://localhost:3000/api/v1/index_project \
  -H "Content-Type: application/json" \
  -d '{"path":"/tmp/demo_projects/blog_rails"}'

curl -X POST http://localhost:3000/api/v1/index_project \
  -H "Content-Type: application/json" \
  -d '{"path":"/tmp/demo_projects/react_todo"}'

curl -X POST http://localhost:3000/api/v1/index_project \
  -H "Content-Type: application/json" \
  -d '{"path":"/tmp/demo_projects/oauth_service"}'
```

### Step 5: Test Q&A Queries
```bash
# Test different query types
curl -X POST http://localhost:3000/api/v1/ask \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Which project used RAG?"}'

curl -X POST http://localhost:3000/api/v1/ask \
  -H "Content-Type: application/json" \
  -d '{"prompt":"What does .map do?"}'

curl -X POST http://localhost:3000/api/v1/ask \
  -H "Content-Type: application/json" \
  -d '{"prompt":"When was my last project with OAuth?"}'

curl -X POST http://localhost:3000/api/v1/ask \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Show me React components"}'

curl -X POST http://localhost:3000/api/v1/ask \
  -H "Content-Type: application/json" \
  -d '{"prompt":"How to implement authentication in Rails?"}'
```

### Step 6: List All Projects
```bash
curl http://localhost:3000/api/v1/projects
```

## 🎯 Expected Results

### Query Examples & Expected Responses

**1. "Which project used RAG?"**
- Should identify the current dev_assistant_api project
- Show RAG service code and implementation details
- Reference specific files and line numbers

**2. "What does .map do?"**
- Find examples across all projects
- Show Ruby and JavaScript implementations
- Provide code examples with explanations

**3. "When was my last project with OAuth?"**
- Identify oauth_service as most recent
- Show OAuth implementation details
- Provide temporal context

**4. "Show me React components"**
- Find React/TypeScript files in react_todo project
- Show TodoList component code
- Provide component structure and usage

**5. "How to implement authentication in Rails?"**
- Find authentication patterns across Rails projects
- Show Devise setup and OAuth implementation
- Provide code examples and best practices

## 🔍 System Features Demonstrated

### Multi-Project Intelligence
- **Project Detection**: Automatically identifies which projects contain relevant code
- **Tech Stack Analysis**: Understands Rails vs React vs Node.js projects
- **Temporal Queries**: "last project", "recent", chronological ordering

### Hybrid Search
- **Semantic Search**: Vector embeddings for conceptual understanding
- **Keyword Matching**: Exact code pattern matching
- **Symbol Relevance**: Function/class name matching
- **File Penalties**: Demotes test files, build artifacts

### RAG Pipeline
- **Context Building**: Combines multiple chunks with project metadata
- **Source Attribution**: Shows exactly where information comes from
- **Intelligent Answers**: LLM responses grounded in retrieved code

## 🛠️ Advanced Testing

### Index Your Own Projects
```bash
# Replace with your actual project paths
curl -X POST http://localhost:3000/api/v1/index_project \
  -H "Content-Type: application/json" \
  -d '{"path":"/home/user/your-project"}'
```

### Test Complex Queries
```bash
# Multi-technology queries
curl -X POST http://localhost:3000/api/v1/ask \
  -d '{"prompt":"Compare authentication approaches across all my projects"}'

# Temporal queries
curl -X POST http://localhost:3000/api/v1/ask \
  -d '{"prompt":"What was my first Rails project?"}'

# Documentation queries
curl -X POST http://localhost:3000/api/v1/ask \
  -d '{"prompt":"How do I set up PostgreSQL in Rails?"}'
```

## 🎉 Success Criteria

Your RAG system is working correctly when:

✅ **Projects are indexed** with proper metadata and tech stack detection
✅ **Queries return relevant code** from appropriate projects
✅ **Answers include source attribution** with file paths and line numbers
✅ **Temporal queries work** ("last", "recent", chronological)
✅ **Multi-project context** is provided in answers
✅ **Different file types** are processed (code, docs, configs)

## 🚀 Next Steps

1. **UI Development**: Build a frontend interface for easier testing
2. **Performance Optimization**: Add caching for large codebases
3. **Advanced Queries**: Add more specialized query handlers
4. **Security**: Add authentication and authorization
5. **Deployment**: Set up production deployment

Your system now provides **intelligent, context-aware answers** about your entire development history - exactly like GitHub Copilot but for your local projects!
