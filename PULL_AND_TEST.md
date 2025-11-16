# Quick Start - Pull and Test v0.3.0

## Step 1: Pull Latest Changes

From your server, pull the latest code from the develop branch:

```bash
cd /var/discourse/plugins/api-topic-views
git pull origin develop
```

## Step 2: Rebuild Discourse

```bash
cd /var/discourse
sudo ./launcher rebuild app
```

This will take several minutes. Wait for it to complete.

## Step 3: Run Diagnostic Script

Once rebuild is complete, enter the container and run the test script:

```bash
sudo ./launcher enter app
rails c
load 'plugins/api-topic-views/TEST_SCRIPT.rb'
```

The script will:
- ✓ Check if plugin is loaded (v0.3.0)
- ✓ Verify settings are configured
- ✓ Confirm controller hooks are registered
- ✓ Test Redis connectivity
- ✓ Generate a test curl command for you

## Step 4: Enable Debug Logging (Optional but Recommended)

To see detailed logs while testing:

1. Exit the Rails console (type `exit`)
2. Exit the container (type `exit`)
3. Edit your app.yml:
   ```bash
   cd /var/discourse
   nano containers/app.yml
   ```

4. Add this under the `env:` section:
   ```yaml
   env:
     LANG: en_US.UTF-8
     API_TOPIC_VIEWS_DEBUG: 'true'
   ```

5. Rebuild:
   ```bash
   sudo ./launcher rebuild app
   ```

## Step 5: Test API Request

The diagnostic script will give you a curl command. Run it from your local machine or server:

```bash
curl -v \
  -H 'Api-Key: YOUR_API_KEY' \
  -H 'Api-Username: system' \
  'https://your-discourse.com/t/123.json'
```

## Step 6: Verify View Count

Check if the topic view count increased:

1. In Rails console:
   ```ruby
   Topic.find(123).views
   ```

2. Or check the logs:
   ```bash
   ./launcher logs app | grep api-topic-views
   ```

You should see logs like:
```
[api-topic-views] ✓ Enqueueing view tracking for topic 123
[api-topic-views] Job executing for topic 123
[api-topic-views] ✓ Topic 123 views: 42 → 43
```

## Troubleshooting

### Views not increasing?

1. **Check plugin is enabled:**
   - Admin → Settings → Search "api_topic_views_enabled"
   - Make sure it's checked (true)

2. **Verify you're using API authentication:**
   - Must have `Api-Key` header
   - Must have `Api-Username` header
   - Regular browser cookies don't count

3. **Check the response status:**
   - Must be 200 OK
   - Use `-v` flag in curl to see response code

4. **Check logs for errors:**
   ```bash
   ./launcher logs app | grep -i error | grep api-topic-views
   ```

### Plugin not loading?

1. Check plugin directory exists:
   ```bash
   ls -la /var/discourse/plugins/api-topic-views/
   ```

2. Check for syntax errors:
   ```bash
   cd /var/discourse/plugins/api-topic-views
   ruby -c plugin.rb
   ```

3. Check rebuild logs:
   ```bash
   ./launcher logs app | head -100
   ```

## What Changed in v0.3.0?

- **New tracking method:** Direct controller hooks instead of middleware
- **Better reliability:** Guaranteed to trigger on every API request
- **Rate limiting:** Now functional (set in admin settings)
- **Bot detection:** Automatically skips bot users
- **Better performance:** Atomic view increments

## Need Help?

- GitHub Issues: https://github.com/gorfist/api-topic-views/issues
- See UPGRADE_GUIDE.md for detailed information
- See README.md for full documentation

