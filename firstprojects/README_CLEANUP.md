Project overview & cleanup notes
================================

This document explains the small refactor and cleanup done, how the app is structured, how to run it, and presentation notes so someone else can follow your code.

1) What I changed
- Removed unused route chip helper from `lib/screens/search_screen.dart` (chips were removed from UI).
- Added a Chatbot UI at `lib/screens/chatbot_screen.dart` that uses the local `AiChatbotService` for offline responses.
- Updated `lib/services/flight_service.dart` previously to allow using a local proxy for web (if present) — check `tools/proxy`.

2) Project structure (important files)
- `lib/main.dart` - app entry
- `lib/screens/search_screen.dart` - main search UI
- `lib/screens/results_screen.dart` - displays search results
- `lib/screens/chatbot_screen.dart` - AI assistant UI (local service)
- `lib/services/flight_service.dart` - real API calls (uses proxy on web)
- `lib/services/ai_chatbot_service.dart` - local AI-like responses for the Chatbot
- `tools/proxy/` - local Dart proxy to add CORS headers when running Flutter web

3) How to run (development)
- Start the proxy (if testing web and backend does not set CORS):
  ```powershell
  cd 'F:\flutter app\OAT-APP\firstprojects\tools\proxy'
  dart pub get
  dart run bin/proxy.dart
  ```

- Run the app (example for Chrome):
  ```powershell
  cd 'F:\flutter app\OAT-APP\firstprojects'
  flutter pub get
  flutter run -d chrome
  ```

4) Why the proxy exists
- Browsers enforce CORS. If the backend at `http://156.67.31.137:3000` doesn't send `Access-Control-Allow-Origin`, browser requests will be blocked.
- The proxy forwards requests to the backend and adds `Access-Control-Allow-Origin: *` for development only.

5) Presentation notes (walkthrough for reviewers)
- Open `lib/main.dart` to see app bootstrapping.
- `SearchScreen` shows the search form; pressing the chat icon opens the assistant.
- `ChatbotScreen` is a local chat UI that calls `AiChatbotService.getResponse(...)` for canned replies — useful for demos without an external LLM.
- `FlightService.searchFlights(...)` performs HTTP GET calls; on the web it uses `http://127.0.0.1:8080` (proxy) while on mobile it calls the real backend.

6) Next suggestions (optional improvements)
- Move styling/color constants to a single `theme.dart` or use `ThemeData` consistently.
- Extract form fields into smaller widgets for reuse and testing.
- Replace the local AI service with a real backend or LLM integration if needed.
- Add unit tests for `AiChatbotService` logic and `FlightService` (mocked HTTP client).

If you want, I can apply the optional suggestions now (theme extraction, config for proxy host, README in project root). Which would you prefer next?
