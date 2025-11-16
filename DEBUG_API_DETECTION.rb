# frozen_string_literal: true
# Quick API Detection Debug Script
# Run in Rails console: load 'plugins/api-topic-views/DEBUG_API_DETECTION.rb'

puts "\n" + "="*80
puts "API DETECTION DEBUG - Checking Environment Variables"
puts "="*80 + "\n"

# Check what Discourse uses to detect API requests
puts "Checking Discourse's API detection methods...\n\n"

# Method 1: Check ApplicationController
if defined?(ApplicationController)
  if ApplicationController.method_defined?(:is_api?)
    puts "✓ ApplicationController has is_api? method"
    puts "  This is what Discourse uses internally to detect API requests"
  else
    puts "⚠ ApplicationController doesn't have is_api? method"
  end
end

# Method 2: Check what TopicsController has
if defined?(TopicsController)
  puts "\n✓ TopicsController is defined"
  
  # Check if our methods are defined
  if TopicsController.private_method_defined?(:track_api_topic_view)
    puts "✓ Our track_api_topic_view method is installed"
  end
  
  if TopicsController.private_method_defined?(:is_api?)
    puts "✓ Our is_api? method is installed"
  end
end

puts "\n" + "-"*80
puts "Environment Variable Names Discourse Uses:"
puts "-"*80

# Let's check how Discourse actually detects API requests
# by looking at the middleware and request handling

puts "\nChecking Discourse source for API detection..."

# Look at CurrentUser which is used by Discourse
if defined?(CurrentUser)
  puts "\n✓ CurrentUser module exists"
  puts "  Methods: #{CurrentUser.methods(false).sort.join(', ')}"
end

# Check if there's an API key in the current context
puts "\n" + "-"*80
puts "Testing with a Real Request Context:"
puts "-"*80

# Find a topic to test with
topic = Topic.where(deleted_at: nil).first
if topic
  puts "\nFound test topic: #{topic.id}"
  puts "Current views: #{topic.views}"
  
  # Try to simulate an API request detection
  puts "\n" + "="*80
  puts "RECOMMENDATION:"
  puts "="*80
  puts "\nMake a test API request and watch the logs in real-time:"
  puts "\n1. In another terminal, run:"
  puts "   cd /var/discourse"
  puts "   ./launcher logs app | grep api-topic-views"
  puts "\n2. Then make this API request (replace YOUR_API_KEY):"
  puts "\n   curl -v \\"
  puts "     -H 'Api-Key: YOUR_API_KEY' \\"
  puts "     -H 'Api-Username: system' \\"
  puts "     '#{Discourse.base_url}/t/#{topic.id}.json'"
  puts "\n3. Watch the logs - you'll see EXACTLY what's being detected:"
  puts "   - Whether is_api? returns true/false"
  puts "   - What headers are present"
  puts "   - Why the request is being tracked or skipped"
  puts "\n" + "="*80
else
  puts "\n⚠ No topics found to test with"
end

puts "\n"

