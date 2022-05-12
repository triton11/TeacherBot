require "dotenv/load"
require_relative "chatbot_query_base"
require_relative "chatbot_logger"
require_relative "one_shots"

class TeacherBot
  def run
    run_program = true

    while run_program do
      # Don't create logfile until we have a subject
      puts("Who do you want to learn about?")
      subject = gets.chomp()
      initialize_variables(subject)
      logger.puts_and_log("Sounds good! Lets learn about #{subject}")
      summary_text = summary(subject)
      additional_info_text = additional_info(subject)
      background_text = summary_text + additional_info_text

      quiz(subject, background_text)

      logger.puts_and_log("Choose another person? Y/N")

      unless (gets.chomp == "Y")
        logger.puts_and_log("Goodbye!")
        run_program = false
      end
    end
  end

  def initialize_variables(subject)
    log_name = ChatBotLogger.generate_title(subject)
    @logger = ChatBotLogger.new(file_name: log_name)
    @chatbot_base = ChatBotQueryBase.new(logger: logger, max_tokens: 50, temperature: 0.4)
  end

  def summary(subject)
    # First, GPT-3 gives a summary of this person's life
    one_line_summary = chatbot_base.generate("#{OneShots::SUMMARY} Who is #{subject}?\n")
    logger.puts_and_log(one_line_summary)

    one_line_summary
  end

  def additional_info(subject)
    logger.puts_and_log("What else can I tell you about #{subject}?")
    logger.puts_and_log("A. Tell me more about their life.")
    logger.puts_and_log("B. Tell me more about their accomplishments.")
    logger.puts_and_log("C. Tell me more about the time period they were alive during.")
    logger.puts_and_log("Or, ask me anything about #{subject}!")

    user_response = logger.gets_and_log
    gpt_answer = ""
    if user_response == "A"
      gpt_answer = chatbot_base.generate("#{OneShots::A_LIFE} Tell me more about #{subject}'s life:\n")
    elsif user_response == "B"
      gpt_answer = chatbot_base.generate("#{OneShots::B_ACCOMPLISHMENTS} Tell me more about #{subject}'s accomplishments:\n")
    elsif user_response == "C"
      gpt_answer = chatbot_base.generate("#{OneShots::C_TIME} Tell me more about the time period #{subject} was alive during:\n")
    else
      gpt_answer = chatbot_base.generate("#{OneShots::D_ANYTHING} Answer the following question about #{subject}: #{user_response}?")
    end
    logger.puts_and_log(gpt_answer)

    gpt_answer
  end

  def quiz(subject, background_text)
    logger.puts_and_log("Time for a quiz!")
    score = 0
    total = 4
    score += quiz_question("true or false", 1, subject, background_text)
    score += quiz_question("multiple choice", 1, subject, background_text)
    score += quiz_question("short answer", 2, subject, background_text)
    logger.puts_and_log("Your score is #{score} out of #{total}")
  end

  def quiz_question(type, value, subject, background_text)
    test_shot = ""
    validation_shot = ""
    if type == "true or false"
      test_shot = OneShots::TRUE_OR_FALSE
      validation_shot = OneShots::VALIDATION_TRUE_OR_FALSE
    elsif type == "multiple choice"
      test_shot = OneShots::MULTIPLE_CHOICE
      validation_shot = OneShots::VALIDATION_MULTIPLE_CHOICE
    else
      test_shot = OneShots::FREE_RESPONSE
      validation_shot = OneShots::VALIDATION_FREE_RESPONSE
    end
    question = chatbot_base.generate(
      "#{test_shot}Based on the information we have learned about #{subject}, including #{background_text}, generate one #{type} question but do not answer it:"
    )
    logger.puts_and_log(question)
    answer = logger.gets_and_log
    validation = gpt_validate(validation_shot, chatbot_base, question, answer)
    logger.puts_and_log(validation)
    score_question(validation, value)
  end

  private

  attr_accessor :logger, :chatbot_base

  def score_question(validation, points)
    parsed_validation = check_question(validation)
    parsed_validation == "correct" ? points : 0
  end

  def check_question(gpt_answer_validation)
    correct_answer_indicators = ["correct", "yes", "true"]
    incorrect_answer_indicators = ["incorrect", "not correct", "not true", "inaccurate", "not accurate", "no"]

    validation = gpt_answer_validation.downcase

    if correct_answer_indicators.any? { |ind| validation.include?(ind) } &&
      !(incorrect_answer_indicators.any? { |ind| validation.include?(ind) })
      "correct"
    else
      "incorrect"
    end
  end

  def gpt_validate(shot, chatbot_base, question, answer)
    # ["correct", "incorrect"].sample
    chatbot_base.generate(
      "#{shot}Is \"#{answer}\" a correct answer to the following question: #{question}? Yes or no?"
    )
  end
end

TeacherBot.new.run
