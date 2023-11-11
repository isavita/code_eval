# CodeEval

`CodeEval` is a Phoenix application that provides an API endpoint to dynamically evaluate Elixir code snippets. It's designed for simplicity and ease of use with basic authentication for secure access.

## Getting Started

To start the `CodeEval` server:

  * Install dependencies with `mix setup`.
  * Start the Phoenix endpoint with `mix phx.server` or within IEx using `iex -S mix phx.server`.

After starting the server, you can access the application at [`localhost:4000`](http://localhost:4000) from your browser.

## API Usage

The application exposes a single API endpoint to evaluate Elixir code:

  * **POST `/api/run`**: This endpoint accepts a JSON payload with Elixir code and returns the evaluation result.

### Request Format

```json
{
  "code": "Elixir code here"
}
```

### Response Format
On successful evaluation including output (e.g. IO.puts):
```json
{
  "result": "Evaluation result",
  "output": "Evaluation output"
}
```
On error:
```json
{
  "error": "Error message"
}
```

## Authentication
The API uses an API key for authentication. When making requests to the /api/run endpoint, you need to include an X-Api-Key header with your API key. The header should be in the following format:
```text
X-Api-Key: your_api_key_here
```
