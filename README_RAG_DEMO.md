# Dev Assistant API - RAG System Demo

This enhanced version transforms your code search into a full multi-project RAG (Retrieval-Augmented Generation) system capable of answering questions about your past projects.

## 🚀 What's New

### Multi-Project Support
- **Project Model**: Tracks multiple repositories with metadata (name, tech stack, creation dates)
- **Enhanced Indexing**: Processes code and documentation files across multiple projects
- **Project Context**: Answers include which projects information comes from

### Enhanced Content Processing
- **Documentation Support**: Now processes `.md`, `.txt`, `.yml`, `.json` files
- **Smart Chunking**: Semantic chunking for both code and documentation
- **Metadata Extraction**: Automatically detects tech stack and project descriptions

### RAG Q&A Pipeline
- **Context-Aware Answers**: Combines retrieved code with LLM responses
- **Source Attribution**: Shows exactly where information comes from
- **Specialized Queries**: Handles "which project", "when was last project", etc.

## 🛠️ Setup

### 1. Run Database Migrations
```bash
rails db:migrate
```

### 2. Start Ollama (for local AI)
```bash
ollama serve
ollama pull mistral
ollama pull nomic-embed-text
```

### 3. Start Rails Server
```bash
rails server
```

### 4. Set Up Demo Data
```bash
ruby test/demo_setup.rb
```

### 5. Test the System
```bash
ruby test/api_demo.rb
```

## 📚 API Endpoints

### Ask Questions
```bash
POST /api/v1/ask
{
  "prompt": "Which project used RAG?"
}
```

Response:
```json
{
  "query": "Which project used RAG?",
  "answer": "Based on the indexed projects, the 'dev_assistant_api' project uses RAG...",
  "sources": [
    {
      "project": "dev_assistant_api",
      "file": "app/services/rag_service.rb",
      "lines": "1-50",
      "symbol": "RagService",
      "relevance": 0.876
    }
  ],
  "projects": [
    {
      "name": "dev_assistant_api",
      "tech_stack": "Ruby on Rails, PostgreSQL, Ollama"
    }
  ]
}
```

### List Projects
```bash
GET /api/v1/projects
```

### Index New Project
```bash
POST /api/v1/index_project
{
  "path": "/path/to/your/project"
}
```

## 🎯 Example Queries

### Project Discovery
- "Which project used RAG?"
- "When was my last project with OAuth?"
- "Show me all React projects"

### Code Understanding
- "What does .map do?"
- "How do I implement authentication in Rails?"
- "Show me TypeScript components"

### Documentation Queries
- "How to set up PostgreSQL in Rails?"
- "What's the OAuth flow?"

## 🔧 System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   User Query   │───▶│   RagService    │───▶│  LlmService    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Projects     │◀───│VectorSearchService│◀───│EmbeddingService│
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CodeChunks   │◀───│  RepoIndexer    │◀───│  CodeChunker   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📊 File Processing

### Supported File Types
- **Code**: `.rb`, `.js`, `.ts`, `.jsx`, `.tsx`
- **Documentation**: `.md`, `.txt`
- **Configuration**: `.yml`, `.yaml`, `.json`

### Chunking Strategy
- **Ruby**: Classes, modules, methods
- **JavaScript/TypeScript**: Functions, components, classes
- **Markdown**: Sections by headings
- **Config Files**: File-level chunks

## 🎯 Key Features

### Hybrid Search
- **Semantic Similarity** (80% weight): Vector embeddings
- **Keyword Matching** (15% weight): Exact code matches
- **Symbol Relevance** (10% weight): Function/class names
- **File Penalties**: Demotes test files, build artifacts

### Project Intelligence
- **Tech Stack Detection**: Automatic identification from files
- **Temporal Queries**: "last project", "recent" support
- **Project Boosting**: Relevant projects get higher scores

### RAG Pipeline
1. **Retrieve**: Find relevant code chunks
2. **Context**: Build project-aware context
3. **Generate**: LLM answers with context
4. **Attribute**: Show sources and projects

## 🧪 Testing

The demo creates three sample projects:
- **blog_rails**: Ruby on Rails blog app
- **react_todo**: React TypeScript todo app  
- **oauth_service**: Rails OAuth authentication service

Each includes realistic code and documentation to test different query types.

## 🚀 Next Steps

1. **Index Your Projects**: Use the API to index your real projects
2. **Custom Queries**: Add specialized query handlers for your needs
3. **UI Development**: Build a frontend interface
4. **Performance**: Optimize for large codebases
5. **Security**: Add authentication and authorization

This transforms your code search into a true AI assistant that understands your entire development history!
