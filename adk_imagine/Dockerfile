FROM python:3.13-slim
WORKDIR /app

# Install uv
RUN pip install uv

# Copy only the pyproject.toml file first to leverage Docker cache
# If you have a lock file (e.g., poetry.lock, pdm.lock), copy it too:
# COPY poetry.lock .
COPY pyproject.toml .

# Install dependencies using uv
# The '.' tells uv to install from pyproject.toml in the current directory
RUN uv pip install --no-cache --system .

# Copy the rest of the application code
COPY . .
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port $PORT"]