# Hotwire Native — Google OAuth Fix

## Problem

Google blocks OAuth sign-in from embedded webviews (WKWebView), which Hotwire Native uses.
The error is `403: disallowed_useragent` — Google's "Use secure browsers" policy.

## Solution

Open the OAuth flow in Safari (system browser) instead of the in-app webview, then bounce back to the app via a custom URL scheme (`shouldplanner://`).

## Implementation Plan

### Rails Side

1. **Add `login_tokens` table** — one-time tokens with expiry
   - `token` (string, unique, indexed)
   - `user_id` (references users)
   - `expires_at` (datetime)

2. **Create `LoginToken` model**
   - Generate secure random token on create
   - Short expiry (~5 minutes)
   - Single-use (delete after exchange)

3. **Update `SessionsController#create`**
   - Detect when the OAuth callback originated from the native app (via a session flag or param)
   - If native: create a `LoginToken`, redirect to `shouldplanner://auth/success?token=TOKEN`
   - If web: keep current behavior (set session, redirect to root)

4. **Add token exchange endpoint** (e.g. `GET /auth/token_login?token=TOKEN`)
   - Find the `LoginToken`, verify it's not expired
   - Set the session cookie for the user
   - Delete the token
   - Redirect to root (the app's webview will pick up the session)

### iOS Side

1. **Register custom URL scheme** in `Info.plist`
   - Add `shouldplanner` as a URL scheme

2. **Intercept login page** in the navigator
   - When the webview navigates to `/login`, open Safari with the OAuth URL instead
   - Append a param (e.g. `?native=1`) so Rails knows to redirect back via the custom scheme

3. **Handle the callback URL** in `SceneDelegate`
   - Implement `scene(_:openURLContexts:)` to catch `shouldplanner://auth/success?token=TOKEN`
   - Make a request to `/auth/token_login?token=TOKEN` in the webview to set the session cookie
   - Navigate to the app's root URL

## Files to Change

### Rails
- `db/migrate/TIMESTAMP_create_login_tokens.rb` (new)
- `app/models/login_token.rb` (new)
- `app/controllers/sessions_controller.rb`
- `config/routes.rb`

### iOS
- `ShouldPlannerApp/Info.plist`
- `ShouldPlannerApp/SceneDelegate.swift`
