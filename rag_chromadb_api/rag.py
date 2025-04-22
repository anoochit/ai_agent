import os
import sys
from dotenv import load_dotenv
import logging # Use logging for better output control

from langchain_community.document_loaders import TextLoader
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings

# Use genai configure for API key handling
from google import genai
from langchain_text_splitters import RecursiveCharacterTextSplitter

# --- FastAPI Imports ---
from fastapi import FastAPI, Query, HTTPException
from contextlib import asynccontextmanager
import uvicorn # For running the app

# --- Setup Logging ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Global State (managed via lifespan) ---
# Using a dictionary to hold state that gets initialized during startup
app_state = {
    "vectorStore": None,
    "embedding_model": None,
    "client": None # Gemini client (optional for search, needed for generation)
}

# --- Initialization Function ---
def initialize_rag():
    """Loads environment variables, data, creates embeddings, and initializes the vector store."""
    logger.info("Initializing RAG system...")

    # Load API keys from .env file
    load_dotenv()
    api_key = os.getenv("GEMINI_API_KEY")

    if not api_key:
        logger.error("GEMINI_API_KEY not found in environment variables.")
        raise ValueError("GEMINI_API_KEY not found in environment variables.")

    # Configure the GenAI client (useful if you add generation later)
    try:
        genai.configure(api_key=api_key)
        client = genai.Client() # Initialize client if needed later
        app_state["client"] = client
        logger.info("Gemini client configured.")
    except Exception as e:
        logger.warning(f"Failed to configure Gemini client: {e}")
        app_state["client"] = None # Ensure client is None if configuration fails

    # --- Paths ---
    current_dir = os.path.dirname(__file__)
    persist_directory = os.path.join(current_dir, "chroma_db")
    # Ensure data directory exists relative to the script
    data_dir = os.path.join(current_dir, "data")
    file_path = os.path.join(data_dir, "pg27827.txt") # Example file name

    # --- Load Document ---
    if not os.path.exists(file_path):
        logger.error(f"Could not find the document at path: {file_path}")
        raise FileNotFoundError(f"Could not find the document at path: {file_path}")

    logger.info(f"Attempting to load document from: {file_path}")
    try:
        loader = TextLoader(file_path, encoding='utf-8')
        documents = loader.load()
    except Exception as e:
        logger.error(f"Error loading document: {e}")
        raise # Re-raise the exception to stop initialization

    # --- Split Document into Chunks ---
    logger.info("Splitting document into chunks...")
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000, chunk_overlap=100)
    texts = text_splitter.split_documents(documents)
    logger.info(f"Split into {len(texts)} chunks.")
    if not texts:
        logger.error("No text chunks were generated after splitting.")
        raise ValueError("No text chunks available to process.")

    # --- Create Embeddings ---
    logger.info("Initializing embedding model...")
    try:
        embedding_model = HuggingFaceEmbeddings(
            model_name="sentence-transformers/all-MiniLM-L6-v2")
        app_state["embedding_model"] = embedding_model
    except Exception as e:
        logger.error(f"Failed to initialize embedding model: {e}")
        raise

    # --- Vector Store Initialization ---
    temp_vector_store = None # Use a temporary variable
    if os.path.exists(persist_directory):
        logger.info(f"Attempting to load existing ChromaDB index from: {persist_directory}")
        try:
            temp_vector_store = Chroma(
                persist_directory=persist_directory,
                embedding_function=app_state["embedding_model"] # Use model from state
            )
            # Basic check if loading seems successful
            count = temp_vector_store._collection.count()
            logger.info(f"Loaded {count} documents from existing DB.")
            if count == 0:
                 logger.warning("Existing DB loaded but contains 0 documents.")
                 # temp_vector_store = None # Force recreation if empty DB is undesirable

        except Exception as e:
            logger.warning(f"Error loading existing ChromaDB: {e}. Will attempt to create a new one.")
            temp_vector_store = None # Ensure it's None if loading failed
            # Consider removing the potentially corrupted directory
            # import shutil
            # try:
            #     shutil.rmtree(persist_directory)
            #     logger.info(f"Removed potentially corrupted directory: {persist_directory}")
            # except OSError as rm_err:
            #     logger.warning(f"Failed to remove directory {persist_directory}: {rm_err}")


    # Create new DB if loading failed or directory didn't exist
    if temp_vector_store is None:
        logger.info("Creating new ChromaDB index...")
        try:
            temp_vector_store = Chroma.from_documents(
                documents=texts, # Use the split texts
                embedding=app_state["embedding_model"], # Use model from state
                persist_directory=persist_directory
            )
            logger.info(f"Created new DB and added {len(texts)} documents.")
            # Optional: Explicitly persist, though from_documents usually handles it
            # temp_vector_store.persist()
        except Exception as e:
            logger.error(f"Error creating new ChromaDB: {e}")
            raise # Stop initialization if DB creation fails

    # Assign to global state only if successful
    app_state["vectorStore"] = temp_vector_store
    logger.info("RAG system initialized successfully.")


# --- Search Function ---
def perform_search(query: str, k: int = 5) -> list[dict]:
    """
    Performs similarity search using the initialized vector store.

    Args:
        query: The search query string.
        k: The number of results to return.

    Returns:
        A list of dictionaries, where each dictionary contains 'page_content'
        and potentially 'metadata' of a relevant document chunk.
        Returns an empty list if no documents are found.

    Raises:
        RuntimeError: If the vector store is not initialized (should not happen if startup succeeded).
        Exception: Propagates errors from the similarity search.
    """
    vectorStore = app_state.get("vectorStore")
    if vectorStore is None:
        # This case should ideally be prevented by successful startup
        logger.error("Vector store accessed before initialization.")
        raise RuntimeError("Vector store is not initialized.")

    logger.info(f"Searching for top {k} chunks relevant to: '{query}'")
    try:
        # Use similarity_search_with_score to potentially get relevance scores too
        # docs = vectorStore.similarity_search_with_score(query, k=k)
        # results = [{"page_content": doc.page_content, "metadata": doc.metadata, "score": score} for doc, score in docs]

        # Or just basic search:
        docs = vectorStore.similarity_search(query, k=k)
        results = [{"page_content": doc.page_content, "metadata": doc.metadata} for doc in docs]

        logger.info(f"Found {len(results)} relevant chunks.")
        return results
    except Exception as e:
        logger.error(f"Error during similarity search for query '{query}': {e}")
        # Re-raise the exception to be caught by the endpoint handler
        raise


# --- FastAPI Lifespan Management ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Code here runs on startup
    logger.info("Application startup...")
    try:
        initialize_rag()
        logger.info("Initialization complete. RAG system ready.")
        yield # The application runs while yielded
    except (ValueError, FileNotFoundError, RuntimeError, Exception) as init_error:
        logger.critical(f"FATAL: Failed to initialize the application: {init_error}", exc_info=True)
        # Optionally, raise the error to prevent FastAPI from starting fully
        # raise init_error
        # Or allow startup but log critical failure
        yield # Allow app to start but it might be non-functional
    finally:
        # Code here runs on shutdown (optional cleanup)
        logger.info("Application shutdown...")
        # Add any cleanup logic if needed (e.g., closing resources)
        app_state["vectorStore"] = None
        app_state["embedding_model"] = None
        app_state["client"] = None


# --- FastAPI App Definition ---
app = FastAPI(
    title="RAG Search API",
    description="API for performing similarity search on documents using ChromaDB and Sentence Transformers.",
    version="1.0.0",
    lifespan=lifespan # Use the lifespan context manager
)

# --- API Endpoints ---
@app.get("/search", summary="Perform Similarity Search", tags=["Search"])
async def search_endpoint(
    query: str = Query(..., description="The search query string.", min_length=1),
    k: int = Query(5, description="Number of results to return.", gt=0) # gt=0 ensures k > 0
):
    """
    Performs similarity search based on the provided query.

    - **query**: The text to search for relevance. (Required)
    - **k**: The maximum number of relevant document chunks to retrieve. (Optional, default: 5)
    """
    if app_state.get("vectorStore") is None:
        # Check if initialization failed during startup
        raise HTTPException(status_code=503, detail="RAG system is not initialized or failed to load.")

    try:
        search_results = perform_search(query, k=k)
        return {
            "query": query,
            "k": k,
            "results": search_results
        }
    except RuntimeError as e:
        # Should be caught by the check above, but as a fallback
        logger.error(f"Runtime error during search: {e}")
        raise HTTPException(status_code=503, detail=str(e))
    except Exception as e:
        # Handle unexpected errors during the search
        logger.error(f"Unexpected error in /search endpoint for query '{query}': {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="An internal server error occurred during search.")


@app.get("/health", summary="Health Check", tags=["Management"])
async def health_check():
    """Checks if the RAG system is initialized and ready."""
    if app_state.get("vectorStore") is not None:
        # You could add a more sophisticated check, e.g., try a dummy search
        return {"status": "OK", "message": "RAG system appears initialized."}
    else:
        # Return 503 if not ready
        raise HTTPException(status_code=503, detail="RAG system not initialized.")


# --- Main Execution (for running with uvicorn directly) ---
if __name__ == '__main__':
    # This block allows running the script directly using `python rag.py`
    # It's often preferred to run uvicorn from the command line for more options:
    # uvicorn rag:app --reload --host 0.0.0.0 --port 8000
    logger.info("Starting Uvicorn server directly...")
    uvicorn.run(
        "rag:app", # Points to the 'app' instance in the 'rag.py' file
        host="0.0.0.0",
        port=8000,
        reload=True # Enable auto-reload for development (remove in production)
        # You might need log_level="info" or "debug" here if logs aren't showing
    )

    # Note: The lifespan event handles the initialization now,
    # so we don't call initialize_rag() directly here.
    # Uvicorn manages the application lifecycle.
