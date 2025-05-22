# RAG Search and Summary API

This project provides a FastAPI-based implementation for a Retrieval-Augmented Generation (RAG) system. It uses ChromaDB for document storage and similarity search, and the Gemini AI model for generating summaries based on retrieved documents.

## Features

- **Document Loading and Splitting**: Load text documents and split them into manageable chunks for processing.
- **Vector Store Initialization**: Create or load a ChromaDB vector store for efficient similarity search.
- **Similarity Search**: Retrieve relevant document chunks based on a query.
- **Summary Generation**: Generate detailed summaries using the Gemini AI model.
- **FastAPI Integration**: Expose the functionality via a RESTful API.

## Requirements

- Python 3.8+
- Required Python packages (see `requirements.txt`)
- `.env` file with the following environment variable:
  - `GEMINI_API_KEY`: Your API key for the Gemini AI model.

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd rag_chromadb_api
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Create a `.env` file and add your Gemini API key:
   ```env
   GEMINI_API_KEY=your_api_key_here
   ```

## Usage

1. Start the FastAPI server:
   ```bash
   uvicorn rag:app --reload --host 0.0.0.0 --port 8000
   ```

2. Send a POST request to the `/search` endpoint with a JSON body:
   ```json
   {
     "query": "Your question here",
     "k": 5
   }
   ```

3. Example response:
   ```json
   {
     "query": "Your question here",
     "summary": "Generated summary here",
     "retrieved_context": "Relevant document chunks here"
   }
   ```

## Project Structure

- `rag.py`: Main application logic.
- `requirements.txt`: Python dependencies.
- `data/`: Directory for storing input documents.
- `chroma_db/`: Directory for storing ChromaDB index.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.