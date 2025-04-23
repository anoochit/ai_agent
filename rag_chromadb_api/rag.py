import os
import logging
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Body
from pydantic import BaseModel
import uvicorn
from contextlib import asynccontextmanager  # Import asynccontextmanager

from langchain_community.document_loaders import TextLoader
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
from google import genai

# --- Configuration & Initialization ---

logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

# Load API keys from .env file
load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise ValueError("GEMINI_API_KEY not found in environment variables.")

# Initialize Gemini Client
try:
    client = genai.Client(api_key=api_key)
    # Test connection (optional but recommended)
    # list(client.models.list())
    logging.info("Gemini Client initialized successfully.")
except Exception as e:
    logging.error(f"Failed to initialize Gemini Client: {e}")
    raise

# --- Global Variables ---
# Using a dictionary to hold state is often preferred over globals with lifespan
app_state = {"vectorStore": None, "embedding_model": None}

# --- Helper Functions ---


def load_and_split_document(file_path: str, chunk_size: int = 1000, chunk_overlap: int = 100) -> list:
    """Loads a text document and splits it into chunks."""
    if not os.path.exists(file_path):
        logging.error(f"Could not find the document at path: {file_path}")
        raise FileNotFoundError(
            f"Could not find the document at path: {file_path}")

    logging.info(f"Attempting to load document from: {file_path}")
    try:
        loader = TextLoader(file_path, encoding='utf-8')
        documents = loader.load()
    except Exception as e:
        logging.error(f"Error loading document: {e}")
        raise

    logging.info("Splitting document into chunks...")
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size, chunk_overlap=chunk_overlap)
    texts = text_splitter.split_documents(documents)
    logging.info(f"Split into {len(texts)} chunks.")
    return texts


def initialize_vector_store(persist_directory: str, texts: list = None) -> Chroma:
    """Initializes or loads the Chroma vector store."""
    # Access embedding model via app_state if needed, or initialize locally
    if app_state["embedding_model"] is None:
        logging.info("Initializing embedding model...")
        app_state["embedding_model"] = HuggingFaceEmbeddings(
            model_name="sentence-transformers/all-MiniLM-L6-v2")
        logging.info("Embedding model initialized.")

    # Use the initialized model
    embedding_function = app_state["embedding_model"]

    loaded_store = None
    if os.path.exists(persist_directory):
        logging.info(
            f"Attempting to load existing ChromaDB index from: {persist_directory}")
        try:
            loaded_store = Chroma(
                persist_directory=persist_directory,
                embedding_function=embedding_function  # Pass the function here
            )
            # Check if the collection exists and has documents
            if loaded_store._collection and loaded_store._collection.count() > 0:
                logging.info(
                    f"Loaded {loaded_store._collection.count()} documents from existing DB.")
                return loaded_store
            else:
                logging.warning(
                    "Existing ChromaDB directory found, but the collection is empty or invalid. Will create a new one.")
                loaded_store = None  # Force creation
        except Exception as e:
            logging.warning(
                f"Error loading existing ChromaDB: {e}. Will attempt to create a new one.")
            loaded_store = None  # Force creation

    # Create new store if loading failed or directory didn't exist or was empty
    if loaded_store is None:
        logging.info("Creating new ChromaDB index...")
        if not texts:
            logging.error(
                "No text chunks provided to create a new vector store.")
            raise ValueError(
                "Cannot create a new vector store without text chunks.")
        try:
            new_store = Chroma.from_documents(
                documents=texts,
                embedding=embedding_function,  # Pass the function here
                persist_directory=persist_directory
            )
            logging.info(f"Created new DB and added {len(texts)} documents.")
            return new_store
        except Exception as e:
            logging.error(f"Error creating new ChromaDB: {e}")
            raise

    # This part should ideally not be reached if logic above is correct
    return loaded_store


def search_documents(query: str, k: int = 5) -> list:
    """Performs similarity search on the vector store."""
    vectorStore = app_state.get("vectorStore")  # Get store from app_state
    if vectorStore is None:
        logging.error(
            "Vector store is not initialized or available in app state.")
        raise ValueError(
            "Vector store not initialized. Cannot perform search.")

    logging.info(f"Searching for chunks relevant to: '{query}'")
    try:
        docs = vectorStore.similarity_search(query, k=k)
        logging.info(f"Found {len(docs)} relevant chunks.")
        return docs
    except Exception as e:
        logging.error(f"Error during similarity search: {e}")
        raise


def generate_summary(query: str, context: str) -> str:
    """Generates a summary using the Gemini model based on context and query."""
    prompt = f"""คุณคือ AI ผู้ช่วยที่ใช้ความรู้จาก Context เพื่อช่วยตอบคำถามของผู้ใช้

Context:
{context}

คำถาม:
{query}

ตอบเป็นภาษาไทยอย่างละเอียด:
"""
    logging.info("Generating response with Gemini...")
    try:
        # Ensure the client is initialized (already done at module level)
        if client is None:
            raise ValueError("Gemini client is not initialized.")

        # Use the correct method for the genai client
        # Note: Corrected the API call based on previous interaction
        response = client.models.generate_content(
            model='models/gemini-1.5-flash',  # Or your preferred model
            contents=prompt
        )
        # Access the text part of the response
        if response.text:
            return response.text
        elif hasattr(response, 'text'):  # Fallback
            return response.text
        else:
            logging.error(f"Unexpected Gemini response structure: {response}")
            raise ValueError("Could not extract text from Gemini response.")

    except Exception as e:
        logging.error(f"Error generating response with Gemini: {e}")
        raise

# --- Lifespan Management ---


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handles application startup and shutdown events."""
    # Startup: Load data and initialize vector store
    logging.info("Application startup: Initializing resources...")
    current_dir = os.path.dirname(__file__)
    persist_directory = os.path.join(current_dir, "chroma_db")
    # Corrected path assuming 'data' is in the same dir as rag.py
    file_path = os.path.join(current_dir, "data", "pg27827.txt")

    try:
        # Load and split only if DB needs creation
        texts = None
        if not os.path.exists(persist_directory):
            logging.info(
                "ChromaDB directory not found. Loading and splitting document for creation.")
            texts = load_and_split_document(file_path)

        # Initialize vector store (will load if exists, create if not)
        # Store the initialized vector store in app_state
        app_state["vectorStore"] = initialize_vector_store(
            persist_directory, texts)
        logging.info("Vector store initialized successfully for API.")

    except FileNotFoundError as e:
        logging.error(f"Startup Error: {e}")
        raise RuntimeError(f"Failed to find document file: {e}") from e
    except Exception as e:
        logging.error(f"Startup Error initializing vector store: {e}")
        raise RuntimeError(f"Failed to initialize vector store: {e}") from e

    yield  # Application runs here

    # Shutdown: Clean up resources (optional here, but good practice)
    logging.info("Application shutdown: Cleaning up resources...")
    app_state["vectorStore"] = None  # Release reference
    app_state["embedding_model"] = None
    # Add any other cleanup needed, e.g., closing connections


# --- FastAPI Application ---

# Pass the lifespan context manager to the FastAPI app
app = FastAPI(
    title="RAG Search and Summary API",
    description="API to search documents using ChromaDB and generate summaries with Gemini.",
    version="1.0.0",
    lifespan=lifespan  # Register the lifespan handler
)


class SearchRequest(BaseModel):
    query: str
    k: int = 5  # Number of documents to retrieve


class SearchResponse(BaseModel):
    query: str
    summary: str
    retrieved_context: str | None = None  # Optional: return context for debugging


@app.post("/search", response_model=SearchResponse)
async def search_and_summarize(request: SearchRequest = Body(...)):
    """
    Receives a query, searches relevant documents, and returns a generated summary.
    """
    # Access vectorStore from app_state
    vectorStore = app_state.get("vectorStore")

    if vectorStore is None:
        # Check if it's None because startup failed or just not available
        if "vectorStore" not in app_state:
            detail_msg = "Vector store failed to initialize during startup."
        else:
            detail_msg = "Vector store is not available or not initialized."
        raise HTTPException(status_code=503, detail=detail_msg)

    try:
        # 1. Search for relevant documents
        # search_documents now uses app_state
        docs = search_documents(request.query, k=request.k)

        if not docs:
            context = "ไม่พบข้อมูลที่เกี่ยวข้องในเอกสาร"  # Provide default context in Thai
            summary = "ขออภัย ไม่พบข้อมูลที่เกี่ยวข้องกับคำถามของคุณในเอกสารที่มีอยู่"
        else:
            # 2. Prepare context
            context = "\n\n---\n\n".join([doc.page_content for doc in docs])

            # 3. Generate summary
            summary = generate_summary(request.query, context)

        return SearchResponse(
            query=request.query,
            summary=summary,
            retrieved_context=context  # Optionally return context
        )

    except ValueError as e:  # Specific errors we raise
        logging.error(f"Search Error (ValueError): {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except HTTPException:  # Re-raise HTTP exceptions
        raise
    except Exception as e:
        logging.error(
            f"Unhandled error during search/summary: {e}", exc_info=True)
        raise HTTPException(
            status_code=500, detail="An internal server error occurred.")

# --- Main Execution Block (for running directly, e.g., testing setup) ---
if __name__ == "__main__":
    # This block remains the same for instructing how to run the server

    print("\nTo run the API server, use the command:")
    print("uvicorn rag:app --reload --host 0.0.0.0 --port 8000")
    print("\nThen send a POST request to http://localhost:8000/search with JSON body like:")
    print('{ "query": "Your question here" }')

    # Example using uvicorn programmatically (less common for production)
    # uvicorn.run(app, host="0.0.0.0", port=8000)
