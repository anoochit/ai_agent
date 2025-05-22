# RAG (Retrieval-Augmented Generation) with ChromaDB

This project demonstrates a Retrieval-Augmented Generation (RAG) pipeline using ChromaDB for vector storage and Gemini AI for content generation. The pipeline processes a document, splits it into chunks, creates embeddings, and allows users to query the document for relevant information.

## Features

- **Document Loading**: Loads a text document from the `data` directory.
- **Text Splitting**: Splits the document into manageable chunks for processing.
- **Vector Storage**: Uses ChromaDB to store and retrieve document embeddings.
- **Querying**: Allows users to ask questions and retrieves relevant document chunks.
- **Content Generation**: Generates detailed answers using Gemini AI.

## Requirements

- Python 3.8+
- Required Python packages (listed in `requirements.txt`):
  - `langchain_community`
  - `langchain_chroma`
  - `langchain_huggingface`
  - `google-genai`
  - `python-dotenv`

## Setup

1. Clone the repository.
2. Install the required packages:
   ```bash
   pip install -r requirements.txt
   ```
3. Add your Gemini API key to a `.env` file in the following format:
   ```env
   GEMINI_API_KEY=your_api_key_here
   ```
4. Place the document to be processed in the `data` directory (e.g., `pg27827.txt`).

## Usage

Run the `rag.py` script to start the pipeline:
```bash
python rag.py
```

You will be prompted to enter a query. The script will retrieve relevant chunks from the document and generate a detailed answer using Gemini AI.

## Directory Structure

```
rag_chromadb/
├── data/                # Directory for input documents
├── chroma_db/           # Directory for ChromaDB index storage
├── rag.py               # Main script for the RAG pipeline
├── requirements.txt     # List of required Python packages
└── README.md            # Project documentation
```

## Notes

- Ensure the ChromaDB index is created before querying. If it doesn't exist, the script will create one automatically.
- The script is designed to handle UTF-8 encoded text files.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.