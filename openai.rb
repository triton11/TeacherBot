require "http"

# Copied from https://www.twilio.com/blog/generating-cooking-recipes-openai-gpt3-ruby
# All credit to Twilio for creating this tutorial
class OpenAI
  URI = "https://api.openai.com/v1"

  def initialize(api_key:)
    @api_key = api_key
  end

  def completion(prompt:, max_tokens: 100, temperature: 0.7)
    response = HTTP.headers(headers).post(
      "#{URI}/engines/text-davinci-002/completions",
      json: {
        prompt: prompt,
        max_tokens: max_tokens,
        temperature: temperature
      }
    )
    response.parse
  end

  private

  attr_reader :api_key, :logger

  def headers
    {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{api_key}"
    }
  end
end