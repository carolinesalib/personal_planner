# Shoulds — Personal Planner

A personal planner/organizer app. Web + iOS (via Hotwire Native).

Ruby 3.4.4 / Rails 8.0.2, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind, Importmap.
See [CLAUDE.md](CLAUDE.md) for architecture, auth setup, and deployment details.

## Running locally

Set the Google OAuth env vars, then start the dev server:

```
export GOOGLE_CLIENT_ID=your-client-id
export GOOGLE_CLIENT_SECRET=your-client-secret
bin/dev
```

## Tests

Unit, model, and request specs (RSpec + Factory Bot):

```
bundle exec rspec
```

### End-to-end (browser) tests

E2E specs live in `spec/features/` and drive a **real Chromium browser** through
Playwright against a real Puma server. They cover the flows that depend on real
browser behavior — navigation across all nav links (`navigation_spec.rb`) and the
onboarding wizard's client-side step-through (`onboarding_wizard_spec.rb`). Pure
server-side logic is covered by faster request specs in `spec/requests/`.

**One-time setup** (installs the Playwright CLI + browser; separate from the app's
importmap JS):

```
npm install
npx playwright install chromium
```

**Run them** (headless, like CI):

```
bundle exec rspec spec/features
```

**Watch them run in a visible browser.** Set `HEADFUL=1` to launch a real Chromium
window, and optionally `SLOWMO=<ms>` to pause between each action so you can follow
along:

```
HEADFUL=1 SLOWMO=400 bundle exec rspec spec/features
```

Run a single example by name:

```
HEADFUL=1 SLOWMO=400 bundle exec rspec spec/features/navigation_spec.rb -e "reaches Week planner and returns"
```

> These specs are `type: :feature`, **not** `type: :system`, on purpose — Rails'
> system-test machinery hijacks the browser lifecycle and suppresses the visible
> window even in headed mode. `:feature` uses the Capybara Playwright driver
> directly, so `HEADFUL=1` actually shows a window. See `spec/support/capybara.rb`.

On failure, a screenshot is saved to `tmp/capybara/` regardless of headed/headless mode.
