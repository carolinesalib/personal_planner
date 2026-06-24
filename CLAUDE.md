# Personal Planner

## What is this?
A personal planner/organizer app. Web + iOS (via Hotwire Native). Built for vibes, built for me.

## Stack
- Ruby 3.4.4 / Rails 8.0.2
- PostgreSQL
- Hotwire (Turbo + Stimulus)
- Hotwire Native (iOS)
- Tailwind CSS
- Propshaft (asset pipeline)
- Importmap (JS modules, no Node/bundler)
- Solid Cache / Solid Queue / Solid Cable

## Auth
Google OAuth via OmniAuth (no Devise). Requires two env vars:
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`

### Google Cloud Console setup
1. Go to https://console.cloud.google.com/apis/credentials
2. Create a new project (or use an existing one)
3. Configure the **OAuth consent screen**:
   - User type: External
   - App name, support email, developer email
   - Scopes: `email`, `profile`
4. Create **OAuth 2.0 Client ID** credentials:
   - Application type: Web application
   - **Authorized redirect URIs:**
     - Development: `http://localhost:3000/auth/google_oauth2/callback`
     - Production: `https://your-domain.com/auth/google_oauth2/callback`
5. Copy the Client ID and Client Secret

### Running locally
Set env vars before starting the server:
```
export GOOGLE_CLIENT_ID=your-client-id
export GOOGLE_CLIENT_SECRET=your-client-secret
bin/dev
```

## Dev commands
- `bin/dev` — start the dev server (Procfile.dev)
- `bundle exec rspec` — run tests
- `bin/rails db:migrate` — run migrations
- `bin/rubocop` — lint
- `bin/brakeman` — security scan

## Testing
- RSpec + Factory Bot (no Minitest)
- TODO: Set up Playwright for Ruby (`playwright-ruby-client` + `capybara-playwright-driver`) for E2E tests

## Design — Pages

### Page 1: "List of Should"
Brain dump checklist for things to do (mainly chores). Instead of keeping it in your
head or telling someone about it, just drop it here and get to it eventually.

- Checklist format
- Checking an item archives it (disappears from main view)
- Link somewhere to view completed/archived items
- User can edit and remove items

### Page 2: "Today's Plan"
Daily checklist to plan the day.

- Recommended 5 priority items per day (can add fewer or more)
- "Extra" section for additional non-priority items
- Separate from the "should" list — this is intentional daily planning

### Page 3: Calendar Planner (name TBD)
Calendar view that lets you plan ahead or look back at previous days.

- Calendar toggle — click a date to open a day-plan view (similar to Page 2)
- Can plan future days or review past days
- Each date shows a completion indicator:
  - Empty circle = no items done
  - Half circle = partially complete
  - Full circle (or emoji) = all items completed

## Notes & Ideas
- Investigate Turbo Snapshots + Service Workers for offline support with Hotwire Native
  (cache pages for offline viewing, queue actions to replay when back online)
- Offline is a future goal, not MVP — start online-only

## Future Ideas
- Sync with external calendar (Google Calendar, Apple Calendar, etc.)
- LLM-powered auto-planning — suggest/generate next day's plan based on
  "should" list, past patterns, calendar events
- Planning at multiple horizons: week, month/quarter, year
- Gratitude panel — appears during day planning but NOT on the daily planner view.
  Entries surface later in a dedicated gratitude section and on the calendar view
- i18n support — Portuguese and English
- Onboarding screens — teach the methodology and let user select language

## Decisions log
- PostgreSQL over SQLite3 — familiar, better fit for multi-platform (web + iOS),
  handles concurrent writes well, easy to deploy on hosted platforms
- Web + Hotwire Native iOS — single Rails codebase serves both platforms
- OmniAuth without Devise — simpler for Google-only login, manual session management
