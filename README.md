# Rick and Morty Database

A SwiftUI iOS application that displays characters from the Rick and Morty universe, with search, status filtering, and character detail views, all powered by the [Rick and Morty API](https://rickandmortyapi.com).

## How to Run

1. Open `RickAndMortyDatabase.xcodeproj` in Xcode.
2. Select an iOS Simulator (iOS 26+).
3. Press `Cmd + R` to build and run.
4. No API key or third-party dependencies are required.

## Architecture

The project follows **MVVM** with a clear three-layer separation:

- `Data/` → Networking (dispatchers, web services, providers, factory)
- `Domain/` → Business logic (view models, models, extensions, constants)
- `Presentation/` → SwiftUI views (list, detail, filters, image handling)

**Why MVVM:** It naturally fits SwiftUI's reactive paradigm. Views observe `@Observable` view models, which coordinate between the UI and the data layer through protocol-based providers. This keeps views thin, logic testable, and layers decoupled.

**Key patterns:**
- **Protocol-oriented networking** — `CharacterProvider` and `CharacterDetailProvider` define what the data layer exposes, making it straightforward to swap implementations (e.g., mock vs. real).
- **Generic views** — `CharacterLabel` and `CharacterDetailView` accept generic `ImageView` and `DisplayableCharacter` types, keeping them reusable and decoupled from concrete implementations.

## Dependency Injection

Constructor injection is used throughout:

- `CharacterViewModel` receives a `CharacterProvider` protocol in its initializer, not a concrete web service.
- `CharacterDetailViewModel` receives a `CharacterDetailProvider` via a default parameter backed by `WebServiceFactory`, but can be overridden for testing.
- `WebServiceFactory` centralizes the creation of networking dependencies. The dispatcher is set once at app launch in `RickAndMortyDatabaseApp.init()`, and all downstream services receive it through the factory.

This approach keeps tests deterministic — `MockCharacterProvider` is injected in tests, ensuring no real network calls are made.

## Testing

**11 unit tests** across two test classes:

### ViewModel Behavior (7 tests)
- Refresh fetches page 1 and populates characters.
- Refresh sets error alert state on failure.
- Pagination appends results without duplicates.
- Pagination stops when beyond the last page.
- Filtered search resets pagination and replaces characters.
- Filtered search passes the correct name/status parameters.
- Filtered search clears characters on 404 (empty results, not an error).

### Service / API Layer (4 tests)
- Successful decoding of a full `CharacterResponse` JSON.
- Decoding fails gracefully with malformed JSON.
- Decoding fails when required fields are missing.
- API error responses do not decode as valid `CharacterResponse`.

All tests use `MockCharacterProvider` with configurable `Result` types and call history tracking, ensuring they are fully deterministic and never hit the network.

## Observability & Security

- **Error handling:** Both the list and detail screens surface errors via alerts with a retry option. The detail screen also provides a dismiss action to navigate back.
- **Rate limiting (429):** The API occasionally returns 429 (Too Many Requests), particularly when navigating quickly between screens. A silent inline retry mechanism with a 500ms delay is implemented across the character list pagination, detail fetch, filtered search, and image loading. See *Future Improvements* for more details.
- **No sensitive data:** The Rick and Morty API requires no authentication, so there are no API keys or tokens to manage. No user data is collected or stored.

## Tradeoffs & Decisions

- **Custom `TextField` over `.searchable`:** On iOS 26, `.searchable` with `.navigationBarDrawer(displayMode: .always)` does not reliably keep the search bar visible, it disappears on scroll and sometimes does not reappear. A custom `TextField` was used instead, styled to match the app's theme, with full control over visibility and behavior.
- **`GET /character/{id}` for detail:** The detail screen fetches character data via a dedicated API call rather than reusing the list item, as recommended by the assignment, to demonstrate proper boundary design between list and detail.
- **Debounce at 300ms:** Search input is debounced to avoid spamming the API on every keystroke. When the character list is already empty (e.g., after a previous failed search), `isFetching` is set immediately to show a loading indicator instead of flashing "No Results Found" during the debounce window.

## Future Improvements

- **Rate limiting strategy:** The current inline retry for 429 responses works but is basic. A more robust approach would involve a centralized retry/backoff layer in the networking stack (e.g., a retry interceptor in the dispatcher) with exponential backoff and a configurable max retry count, rather than handling retries at each individual call site.
- **View reuse:** Several views share similar styling patterns (green borders, rounded rectangles, OCR-B font). Extracting these into shared view modifiers or reusable styled components would reduce duplication and make call sites simpler.
- **Accessibility:** Adding proper accessibility labels, traits, and dynamic type support to improve the experience for all users.
- **Offline support / caching:** Implementing a lightweight caching layer so previously loaded characters are available without a network connection.
- **UI tests:** Adding UI tests to verify end-to-end flows like search, filter, pagination, and navigation to detail.
