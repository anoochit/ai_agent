import os
from dotenv import load_dotenv

from langchain_community.document_loaders import TextLoader
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings

from google import genai
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Load API keys from .env file
load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise ValueError("GEMINI_API_KEY not found in environment variables.")


client = genai.Client(api_key=api_key)

# Load document
current_dir = os.path.dirname(__file__)
persist_directory = os.path.join(current_dir, "chroma_db")
file_path = os.path.join(current_dir, "data", "pg27827.txt")

if not os.path.exists(file_path):
    raise FileNotFoundError(
        f"Could not find the document at path: {file_path}")

print(f"Attempting to load document from: {file_path}")

try:
    loader = TextLoader(file_path, encoding='utf-8')
    documents = loader.load()
    texts = documents
except Exception as e:
    print(f"Error loading document: {e}")
    exit()

# Split Document into Chunks
print("Splitting document into chunks...")
# Adjust chunk_size and chunk_overlap as needed
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000, chunk_overlap=100)
texts = text_splitter.split_documents(documents)
print(f"Split into {len(texts)} chunks.")


# Create embeddings
embedding_model = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-MiniLM-L6-v2")

# Vector store
vectorStore = None
if os.path.exists(persist_directory):
    print(f"Loading existing ChromaDB index from: {persist_directory}")
    try:
        vectorStore = Chroma(
            persist_directory=persist_directory,
            embedding_function=embedding_model
        )
        print(
            f"Loaded {vectorStore._collection.count()} documents from existing DB.")
    except Exception as e:
        print(
            f"Error loading existing ChromaDB: {e}. Will attempt to create a new one.")
        # Optionally remove the potentially corrupted directory here if needed
        # import shutil
        # shutil.rmtree(persist_directory)

# Check if loading failed or directory didn't exist
if vectorStore is None:
    print("Creating new ChromaDB index...")
    if not texts:
        print("Error: No text chunks to add to the vector store.")
        exit()
    try:
        vectorStore = Chroma.from_documents(
            documents=texts,  # Use the split texts
            embedding=embedding_model,
            persist_directory=persist_directory
        )
        print(f"Created new DB and added {len(texts)} documents.")
        # Optional: Persist explicitly if needed, though from_documents usually does
        # vectorStore.persist()
    except Exception as e:
        print(f"Error creating new ChromaDB: {e}")
        exit()


# Ask question
# - How to increase woman's sexual desire
# - Enlarge lingam
query = input("❓ Ask! Vatsyayana: ")

# Search relevant chunks
print(f"Searching for chunks relevant to: '{query}'")
# Explicitly set k if you want a specific number of results
# Otherwise, it uses the default (often 4)
try:
    docs = vectorStore.similarity_search(
        query, k=3)  # Example: Get top 4 chunks
    print(f"Found {len(docs)} relevant chunks.")
    if not docs:
        print("No relevant documents found.")
        # Handle case where no documents are found if necessary
        context = "ไม่พบข้อมูลที่เกี่ยวข้อง"  # Provide default context
    else:
        # Add separators
        context = "\n\n---\n\n".join([doc.page_content for doc in docs])
except Exception as e:
    print(f"Error during similarity search: {e}")
    exit()

# Generate answer
prompt = f"""คุณคือ AI ผู้ช่วยที่ใช้ความรู้จาก Context เพื่อช่วยตอบคำถามของผู้ใช้

Context:
{context}

คำถาม:
{query}

ตอบเป็นภาษาไทยอย่างละเอียด:
"""

# print("\n📣 prompt : \n", prompt)


print("Generating response...")
try:
    response = client.models.generate_content(
        model='gemini-2.0-flash', contents=prompt
    )

    print("\n📣 คำตอบ:\n", response.text)

except Exception as e:
    print(f"\nError generating response with Gemini: {e}")
