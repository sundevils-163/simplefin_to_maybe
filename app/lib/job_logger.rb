module JobLogger
  def logger
    @logger ||= ActiveSupport::TaggedLogging.new(Logger.new(Rails.root.join("log", "simplefin_to_maybe.log"), 5, 10 * 1024 * 1024))
    @logger.level = Logger::INFO
    #@logger.formatter = Logger::Formatter.new
    @logger
  end
end
