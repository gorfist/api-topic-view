# API Topic Views Plugin

This Discourse plugin counts eligible API requests as topic views so that API
traffic (for example, mobile or partner integrations) contributes to analytics
just like regular web requests.

## How It Works

- Hooks into `Middleware::RequestTracker` via
  `ApiTopicViews::RequestLogger.register!`.
- Verifies the request is an API/user-API call, non-background, non-crawler, and
  returned `200`.
- Optionally enforces a custom header before counting the view.
- Extracts the topic id from routes that look like `/t/:slug/:id`.
- Defers to `TopicsController.defer_topic_view` with the resolved user/ip.

```ruby
ApiTopicViews::RequestLogger.register!
```

## Configuration

All settings live under `plugins > api_topic_views` in the admin panel:

| Setting | Description |
| --- | --- |
| `api_topic_views_enabled` | Master flag to enable the tracker (default on). |
| `api_topic_views_require_header` | Header name (e.g. `X-Count-As-View`) that must be present to count a view. Leave blank to accept all API requests. |
| `api_topic_views_max_per_minute_per_ip` | Placeholder for future rate limiting (0 = unlimited). |

If you require a header, make sure your API clients send it as part of every
topic request.

## Installation

1. Add to your container’s `app.yml`:
   ```
   - git clone https://github.com/gorfist/api-topic-view.git
   ```
2. Rebuild the container (`./launcher rebuild app`).
3. Enable the plugin and tweak settings in the admin panel.

## Development

```
bundle exec rake plugin:spec
```

The plugin is small and hooks in at boot, so no additional migrations or assets
are required.