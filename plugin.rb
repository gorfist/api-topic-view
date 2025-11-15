# frozen_string_literal: true

# name: api-topic-views
# about: Count selected API requests as topic views
# version: 0.1
# authors: Cursor Assistant
# url: https://github.com/your-org/api-topic-views

enabled_site_setting :api_topic_views_enabled

load File.expand_path("../lib/api_topic_views/request_logger.rb", __FILE__)

after_initialize do
  ApiTopicViews::RequestLogger.register!
end

