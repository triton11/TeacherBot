require "dotenv/load"
require_relative "openai"
require_relative "chatbot_logger"

class ChatBotQueryBase

  def initialize(logger:, max_tokens: 100, temperature: 0.7)
    @logger = logger
    @max_tokens = max_tokens
    @temperature = temperature
    logger.log("Max tokens: #{max_tokens}, Temperature: #{temperature}", "PARAMETERS")
  end

  def generate(query)
    logger.log(query, "QUERY")
    result = openai.completion(
      prompt: query
    )
    logger.log(result, "RESPONSE")
    result.dig("choices").first.dig("text")
  end

  private

  attr_reader :query, :logger

  def openai
    OpenAI.new(api_key: ENV["OPENAI_KEY"])
  end
end