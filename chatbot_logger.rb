class ChatBotLogger
  LOG_TYPES = ["OUTPUT", "INPUT", "QUERY", "RESPONSE", "PARAMETERS"]

  def self.generate_title(subject)
    "#{Time.now.strftime('%y_%m_%d_%H%M%S_%p')}_#{subject.downcase.tr(' ', '_')}"
  end

  def initialize(file_name:)
    @file_name = file_name
  end

  def gets_and_log
    input_value = gets.chomp
    log(input_value, "INPUT")
    input_value
  end

  def puts_and_log(output)
    puts(output)
    puts()
    log(output, "OUTPUT")
  end

  def log(output, type)
    unless LOG_TYPES.include?(type)
      raise "Unknown log type"
    end
    File.open("chatbot_runs/#{file_name}.txt", "a") do |f| 
      f.write("#{timestamp} #{type} #{output} \n")
    end
  end

  private

  def timestamp
    Time.now.to_i
  end

  attr_reader :file_name
end