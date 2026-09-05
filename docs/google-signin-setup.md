# Wiring up "Sign in with Google"

Everything on the code/infra side is done — the site, the Supabase project,
and the database are ready. The one piece that has to happen by hand is
creating the OAuth client in Google Cloud Console, because Google doesn't
expose an API for it (it's tied to the OAuth consent screen, which only a
human can configure).

## What's already set up for you

- **GCP project**: `coronado-tram-29703`, billing linked to the
  **GuardianHeart** billing account, with a **$25/mo budget alert**
  (50/90/100% thresholds) scoped to just this project.
- **Supabase project**: `coronado-tram` (ref `kjaeqgzawlprxovpsadq`), org
  MahaSankalpam. Schema (`posts`, `reservations`, `meetings`, `travelogue`)
  and Realtime are live. `config.js` already points at it.
- **Site code**: `auth.js` renders a "Sign in with Google" link in the
  header nav on every page, and the free-text name field on the community
  board and the schedule/cart form locks to your Google name once you're
  signed in. None of this requires you to touch code — just the two steps
  below.

## Step 1 — OAuth consent screen (one-time)

1. Open the consent screen page for the project:
   https://console.cloud.google.com/apis/credentials/consent?project=coronado-tram-29703
2. User type: **External** (your 12 neighbors are outside any Google
   Workspace org).
3. App name: `The Coronado Tram`. Support email + developer contact: your
   email.
4. Authorized domain: `thegreatcoronadotram.com`
5. Scopes: leave the defaults (`openid`, `email`, `profile`) — don't add
   anything. With only these basic scopes, Google does **not** require app
   verification, so you can publish straight to production instead of
   staying in "Testing" (which would otherwise cap you at 100 manually
   added test users).
6. Publishing status: **In production**.

## Step 2 — Create the OAuth Client ID

1. Go to https://console.cloud.google.com/apis/credentials?project=coronado-tram-29703
2. **Create Credentials → OAuth client ID**
3. Application type: **Web application**
4. Name: `Coronado Tram - Supabase`
5. Authorized JavaScript origins: `https://thegreatcoronadotram.com`
6. Authorized redirect URIs:
   `https://kjaeqgzawlprxovpsadq.supabase.co/auth/v1/callback`
7. Create it, then copy the **Client ID** and **Client secret** it shows you.

## Step 3 — Wire the credentials in

Two ways to finish — pick whichever's easier:

**Option A — hand them to me.** Paste the Client ID and secret back in
this conversation and I'll fill in `supabase/config.toml`'s
`[auth.external.google]` block (already scaffolded, just disabled) and run
`supabase config push` to enable it on the live project — no dashboard
clicking needed.

**Option B — do it yourself in the Supabase dashboard.**
1. https://supabase.com/dashboard/project/kjaeqgzawlprxovpsadq/auth/providers
2. Enable **Google**, paste the Client ID + secret, Save.

Either way, the moment it's enabled, the "Sign in with Google" link in the
site header will work — no further deploy needed.
