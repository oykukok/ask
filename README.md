# ask

A CLI tool that sends prompts to an LLM API from the command line.

## Dependencies

- `curl`
- `jq`

## Setup

Set the following environment variables:

export ASK_API_URL="https://api.groq.com/openai/v1/chat/completions"
export ASK_MODEL="llama-3.3-70b-versatile"
export ASK_API_KEY="your-api-key-here"

Make the script executable:

chmod +x ask

## Usage

Simple prompt:
ask "What is the capital of France?"

Multiple arguments:
ask "Establishment dates of" "Turkey" "Azerbaijan" "Japan"

Piped input:
cat script.sh | ask "What does this do?"

## Known limitations

- Only supports single-turn conversations (no chat history)
- Requires curl and jq to be installed
- API key and URL must be set as environment variables before use

## License

MIT
