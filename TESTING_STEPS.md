# Complete Testing Steps - v0.3.0

Follow these steps in order to test the API view tracking.

## Step 1: Pull Latest Changes

```bash
cd /var/discourse/plugins/api-topic-views
git pull origin develop
```

You should see it pull the latest commit with the API detection fix.

## Step 2: Rebuild Discourse

```bash
cd /var/discourse
sudo ./launcher rebuild app
```

⏳ This will take 5-10 minutes. Wait for it to complete.

## Step 3: Verify Plugin Loaded

After rebuild completes:

```bash
sudo ./launcher enter app
rails c
```

In Rails console:

```ruby
# Check plugin version
Discourse.plugins.find { |p| p.name == 'api-topic-views' }&.metadata&.version

# Should output: "0.3.0"

# Check if controller hook is registered
TopicsController.private_method_defined?(:track_api_topic_view)

# Should output: true

# Exit console
exit
```

## Step 4: Get Your API Key

You need your actual API key. Get it from:
- Admin Panel → API → New API Key
- Or use an existing one (copy the key when you first create it - it's only shown once)

If you don't have one:
1. Go to Admin → API
2. Click "New API Key"
3. Give it a description (e.g., "Testing API Views")
4. Set User Level: "All Users"
5. Click "Generate Key"
6. **COPY THE KEY IMMEDIATELY** (you won't see it again!)

## Step 5: Test with API Request

Open TWO terminal windows:

### Terminal 1: Watch Logs (FIRST)
```bash
cd /var/discourse
./launcher logs app -f | grep --line-buffered api-topic-views
```

Leave this running! It will show logs as they happen.

### Terminal 2: Make API Request

```bash
# Replace YOUR_API_KEY with your actual key
# Replace YOUR_DISCOURSE_URL with your actual URL

curl -v \
  -H "Api-Key: YOUR_API_KEY" \
  -H "Api-Username: system" \
  "https://YOUR_DISCOURSE_URL/t/1.json"
```

Example:
```bash
curl -v \
  -H "Api-Key: abc123def456..." \
  -H "Api-Username: system" \
  "https://forum.example.com/t/1.json"
```

## Step 6: Watch Terminal 1 for Logs

You should immediately see output like this in Terminal 1:

```
[api-topic-views] ========== Request to /t/1.json ==========
[api-topic-views] Plugin enabled: true
[api-topic-views] Response status: 200
[api-topic-views] @topic present: true
[api-topic-views] @topic.id: 1
[api-topic-views] is_api?: true
[api-topic-views] is_user_api?: false
[api-topic-views] Combined is_api_request: true
[api-topic-views] HTTP_API_KEY present: true
[api-topic-views] HTTP_API_USERNAME present: true
[api-topic-views] ✓ Enqueueing view tracking for topic 1, user: system, ip: xxx.xxx.xxx.xxx
[api-topic-views] Job executing for topic 1, ip: xxx.xxx.xxx.xxx, user: 1
[api-topic-views] ✓ Topic 1 views: 0 → 1
```

## Step 7: Verify View Count

In Rails console:

```ruby
Topic.find(1).views
```

The number should have increased!

## Troubleshooting

### No logs at all after API request

**Check 1:** Is the plugin loaded?
```bash
./launcher enter app
rails c
Discourse.plugins.map(&:name)
# Should include "api-topic-views"
```

**Check 2:** Did you rebuild after pulling changes?
```bash
./launcher rebuild app
```

**Check 3:** Is debug logging enabled?
```bash
./launcher enter app
printenv | grep API_TOPIC_VIEWS_DEBUG
# Should output: API_TOPIC_VIEWS_DEBUG=true
```

If not, add to `containers/app.yml`:
```yaml
env:
  LANG: en_US.UTF-8
  API_TOPIC_VIEWS_DEBUG: 'true'
```

Then rebuild.

### Logs show "Not an API request, skipping"

This means the API key headers aren't being detected. Check:

1. **Headers are correct:**
   - Must be `Api-Key` (capitalized K)
   - Must be `Api-Username` (capitalized U)

2. **Using the correct format:**
   ```bash
   -H "Api-Key: your_key_here"
   -H "Api-Username: system"
   ```

3. **API key is valid:**
   - Not revoked
   - Created in Admin → API

### Response is 404 or 403

- Topic might not exist (try different topic ID)
- API key might not have permission
- API key might be revoked

### Response is 301/302 redirect

- Add trailing `.json` to the URL
- Use the full canonical URL
- Check if your Discourse requires HTTPS

### Job executes but views don't increase

Check logs for:
- Rate limiting messages (if you set a limit)
- Topic not found errors
- Deleted topic messages

## Quick Commands Reference

```bash
# Pull latest code
cd /var/discourse/plugins/api-topic-views && git pull origin develop

# Rebuild
cd /var/discourse && sudo ./launcher rebuild app

# Watch logs
./launcher logs app -f | grep --line-buffered api-topic-views

# Enter Rails console
./launcher enter app
rails c

# Check plugin
Discourse.plugins.find { |p| p.name == 'api-topic-views' }&.metadata&.version

# Check topic views
Topic.find(1).views

# Run diagnostic script
load 'plugins/api-topic-views/TEST_SCRIPT.rb'
```

## Success Criteria

✅ Plugin version shows "0.3.0"  
✅ Logs appear when making API request  
✅ Logs show "is_api?: true"  
✅ Logs show "✓ Enqueueing view tracking"  
✅ Logs show "✓ Topic X views: N → N+1"  
✅ Topic.find(X).views increases after each API request  

If all criteria pass, the plugin is working correctly! 🎉

