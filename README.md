## Quote Vault

A Flutter quotes app backed by Supabase (auth + storage) with favorites, collections, and a “Quote of the Day” widget on Android.

### Prerequisites

- **Flutter SDK**: Stable channel (check with `flutter --version`)
- **Dart SDK**: \(>= 3.10.4\) (see `pubspec.yaml`)
- **Android**: Android Studio + Android SDK / emulator (or a physical device)
- **iOS**: Xcode (macOS only) + iOS Simulator (or a physical device)

### Project Setup

- **Clone the repository**

```bash
git clone https://github.com/VinayaAugusthy/QuoteVault.git
cd quote_vault
```

- **Install dependencies**

```bash
flutter pub get
```

- **Run the app (debug)**

```bash
flutter run --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

#### Easier local dev (recommended)

1) Copy `dart_defines.json.example` → `dart_defines.json` (ignored by git)  
2) Fill in your values  
3) Run:

```bash
flutter run --dart-define-from-file=dart_defines.json
```

### Supabase Setup

#### 1) Create a Supabase project

- Create a new project in Supabase.
- Note your **Project URL** and **Anon (public) key** (see “Project Settings” → “API”).

#### 2) Enable Email/Password authentication

- Go to “Authentication” → “Providers” and enable **Email** (Email/Password).

#### 3) Create required tables

This app uses these tables:

- **`quotes`** (public quote catalog)
- **`profiles`** (user settings/preferences)
- **`user_favorites`** (favorites join table)
- **`collections`** (user collections)
- **`collection_quotes`** (collection items join table)

Minimal schema (you can paste this in Supabase SQL Editor and adjust as needed):

```sql
-- Quotes
create table if not exists public.quotes (
  id uuid primary key default gen_random_uuid(),
  external_id text unique,
  body text not null,
  author text not null,
  category text not null default 'General',
  tags text[] not null default '{}',
  created_at timestamptz not null default now()
);

-- Profiles (user settings)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  theme_mode text,
  accent_color text,
  font_scale double precision,
  updated_at timestamptz not null default now()
);

-- Favorites (join)
create table if not exists public.user_favorites (
  user_id uuid not null references auth.users (id) on delete cascade,
  quote_id uuid not null references public.quotes (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, quote_id)
);

-- Collections
create table if not exists public.collections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

-- Collection items (join)
create table if not exists public.collection_quotes (
  user_id uuid not null references auth.users (id) on delete cascade,
  collection_id uuid not null references public.collections (id) on delete cascade,
  quote_id uuid not null references public.quotes (id) on delete cascade,
  created_at timestamptz not null default now(),
  -- Note: app upserts on (user_id, quote_id)
  unique (user_id, quote_id)
);
```

#### 4) Row Level Security (RLS) note (important)

- Enable **RLS** on user-owned tables: `profiles`, `user_favorites`, `collections`, `collection_quotes`.
- Add policies so a user can only read/write their own rows (typically `user_id = auth.uid()` or `id = auth.uid()` for `profiles`).
- For `quotes`, many apps allow **read-only** access for everyone (or for authenticated users), and keep writes restricted (e.g., via server/admin tooling).

Example policies (adjust to your needs):

```sql
-- Enable RLS
alter table public.profiles enable row level security;
alter table public.user_favorites enable row level security;
alter table public.collections enable row level security;
alter table public.collection_quotes enable row level security;
alter table public.quotes enable row level security;

-- PROFILES: user can read/update their own profile row (id = auth.uid())
create policy "profiles_select_own"
on public.profiles for select
to authenticated
using (id = auth.uid());

create policy "profiles_upsert_own"
on public.profiles for insert
to authenticated
with check (id = auth.uid());

create policy "profiles_update_own"
on public.profiles for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

-- FAVORITES: user can manage their own favorites rows
create policy "favorites_select_own"
on public.user_favorites for select
to authenticated
using (user_id = auth.uid());

create policy "favorites_insert_own"
on public.user_favorites for insert
to authenticated
with check (user_id = auth.uid());

create policy "favorites_delete_own"
on public.user_favorites for delete
to authenticated
using (user_id = auth.uid());

-- COLLECTIONS: user can CRUD their own collections
create policy "collections_select_own"
on public.collections for select
to authenticated
using (user_id = auth.uid());

create policy "collections_insert_own"
on public.collections for insert
to authenticated
with check (user_id = auth.uid());

create policy "collections_update_own"
on public.collections for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "collections_delete_own"
on public.collections for delete
to authenticated
using (user_id = auth.uid());

-- COLLECTION ITEMS: user can manage their own collection items
create policy "collection_quotes_select_own"
on public.collection_quotes for select
to authenticated
using (user_id = auth.uid());

create policy "collection_quotes_insert_own"
on public.collection_quotes for insert
to authenticated
with check (user_id = auth.uid());

create policy "collection_quotes_delete_own"
on public.collection_quotes for delete
to authenticated
using (user_id = auth.uid());

-- QUOTES: allow read; keep writes restricted (seeding uses service role key)
create policy "quotes_select_all"
on public.quotes for select
to anon, authenticated
using (true);
```

Notes:

- If you want to require login to read quotes, remove `anon` from `quotes_select_all`.
- Seeding uses a **service role key**, which bypasses RLS (do not put it in the mobile app).

### Environment Variables

This repo uses **build-time defines** for the Flutter app, and environment variables for the **database seeding script**.

#### Create a `.env` file at the project root

Copy `./env.example` → `./.env` :

```bash
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# FavQs (used by the seeding script). The script reads FAVQS_API_TOKEN today;
# you can set both to the same value for convenience.
FAVQS_API_TOKEN=your_favqs_api_key

# Used ONLY for seeding (server/admin). Never ship this in the app.
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

- **`SUPABASE_URL`**: From Supabase “Project Settings” → “API” → Project URL
- **`SUPABASE_ANON_KEY`**: From Supabase “Project Settings” → “API” → anon public key
- **`FAVQS_API_KEY` / `FAVQS_API_TOKEN`**: From your FavQs account (used to seed quotes)
- **Do not commit secrets**: add `.env` to `.gitignore` (and never hardcode keys in code)

Note: the Flutter app does **not** load `.env` automatically; you still need to pass `--dart-define=...` (or set these defines in your IDE run configuration).

### Database Seeding (FavQs → Supabase)

This repo includes a seeding script at `tool/seed_quotes.dart` that fetches quotes from FavQs and upserts them into Supabase (`quotes.external_id` is used to avoid duplicates).

- **API key required**: FavQs requires an API token/key to access the quotes API.
- **Rate limits**: FavQs may rate-limit requests; if you hit limits, rerun later or lower the seed size.
- **How to trigger seeding**
  - **Windows (recommended)**: run `run_seed.ps1` (loads `./.env` and executes the script)
  - **Manual**: set environment variables and run `dart run tool/seed_quotes.dart`

Example (PowerShell):

```powershell
.\run_seed.ps1
```

Security note: seeding typically needs elevated Supabase access. Use a **service role key** only in local/admin tooling (never in the Flutter app).

### Running the App

#### Debug

```bash
flutter run --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

#### Release

- **Android (APK)**:

```bash
flutter build apk --release --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

- **iOS** (macOS only):
  - Use Xcode for signing, then build/run via Xcode or `flutter build ios --release`.

#### Android “Quote of the Day” AppWidget (native worker)

The Android widget worker reads Supabase values from **Gradle BuildConfig**. You can provide them via either:

- Environment variables: `SUPABASE_URL` / `SUPABASE_ANON_KEY`, or
- `android/local.properties` (not committed), e.g.

```properties
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```
