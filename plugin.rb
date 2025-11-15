# frozen_string_literal: true

# name: api-topic-views
# about: Count selected API requests as topic views
# version: 0.1
# authors: Cursor Assistant
# url: https://github.com/your-org/api-topic-views

begin
  enabled_site_setting :api_topic_views_enabled
rescue => e
  # Silently handle errors during migrations
end

begin
  load File.expand_path("../lib/api_topic_views/request_logger.rb", __FILE__)
rescue => e
  # Silently handle load errors during migrations
end

begin
  after_initialize do
    begin
      ApiTopicViews::RequestLogger.register! if defined?(ApiTopicViews::RequestLogger)
    rescue => e
      # Silently fail during migrations or when components are not available
    end
  end
rescue => e
  # Silently handle errors if after_initialize isn't available
end

