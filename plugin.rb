# frozen_string_literal: true

# name: api-topic-views
# about: Count selected API requests as topic views
# version: 0.1
# authors: Cursor Assistant
# url: https://github.com/your-org/api-topic-views

enabled_site_setting :api_topic_views_enabled

begin
  load File.expand_path("../lib/api_topic_views/request_logger.rb", __FILE__)
rescue => e
  # Silently handle load errors during migrations
end

after_initialize do
  begin
    ApiTopicViews::RequestLogger.register! if defined?(ApiTopicViews::RequestLogger)
  rescue => e
    # Silently fail during migrations or when components are not available
    Rails.logger.warn("[api-topic-views] Failed to initialize: #{e.message}") if defined?(Rails) && defined?(Rails.logger)
  end
end

