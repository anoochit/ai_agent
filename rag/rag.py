import os
from dotenv import load_dotenv

from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings


from google import genai
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Load API keys from .env file
load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")

client = genai.Client(api_key=api_key)

# Load document
current_dir = os.path.dirname(__file__)
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
    
    # Split Document into Chunks
print("Splitting document into chunks...")
# Adjust chunk_size and chunk_overlap as needed
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000, chunk_overlap=100)
texts = text_splitter.split_documents(documents)
print(f"Split into {len(texts)} chunks.")


# Create embeddings & vector store
embedding_model = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-MiniLM-L6-v2")

if not os.path.exists("faiss_index"):
    print("Creating new FAISS index...")
    vectorStore = FAISS.from_documents(texts, embedding_model)
    vectorStore.save_local("faiss_index")
else:
    print("Loading existing FAISS index...")
    vectorStore = FAISS.load_local(
        "faiss_index",
        embedding_model,
        allow_dangerous_deserialization=True)


# Ask question
# - How to increase woman's sexual desire
# - Enlarge lingam
query = input("❓ Ask! Vatsyayana: ")

# Search relevant chunks
print(f"Searching for chunks relevant to: '{query}' \n")
# Explicitly set k if you want a specific number of results
# Otherwise, it uses the default (often 4)

# Search relevant chunks
try:
    docs = vectorStore.similarity_search(
        query, k=4)  # Example: Get top 4 chunks
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

# Generate answer using Gemini 
prompt = f"""คุณคือ AI ผู้ช่วยที่ใช้ความรู้จาก Context เพื่อช่วยตอบคำถามของผู้ใช้

Context:
{context}

คำถาม:
{query}

ตอบเป็นภาษาไทยอย่างละเอียด:
"""


response = client.models.generate_content(
    model='gemini-2.0-flash', contents=prompt
)
print("\n📣 คำตอบ:\n", response.text)
