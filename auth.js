// Shared "Sign in with Google" widget — used by all pages.
// Requires SUPABASE_URL / SUPABASE_ANON_KEY / CONFIGURED (config.js) and the
// supabase-js UMD build to already be loaded before this script runs.
//
// Identity-attribution only: signing in does NOT gate access to the site —
// anyone can still browse and post. It just replaces the free-text name
// field on the board/schedule with your real Google name, so posts and
// reservations are attributed to a real person instead of typed text.
//
// Renders into <span id="auth-widget"> in the header nav, and exposes
// window.coronadoAuth = { client, user } plus a 'coronado-auth-change'
// event on `document` (detail = the signed-in user, or null) that pages
// listen for to swap their name inputs.

window.coronadoAuth = { client: null, user: null };

(function () {
  if (typeof CONFIGURED === 'undefined' || !CONFIGURED) return; // no backend configured — skip auth entirely

  const { createClient } = supabase;
  const authClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  window.coronadoAuth.client = authClient;

  function renderWidget(user) {
    const el = document.getElementById('auth-widget');
    if (!el) return;
    if (user) {
      const name = user.user_metadata?.full_name || user.user_metadata?.name || user.email || 'Signed in';
      el.innerHTML = `<span class="auth-name">${name}</span><a href="#" id="auth-signout">Sign out</a>`;
      document.getElementById('auth-signout').addEventListener('click', e => {
        e.preventDefault();
        authClient.auth.signOut();
      });
    } else {
      el.innerHTML = `<a href="#" id="auth-signin">Sign in with Google</a>`;
      document.getElementById('auth-signin').addEventListener('click', e => {
        e.preventDefault();
        authClient.auth.signInWithOAuth({
          provider: 'google',
          options: { redirectTo: window.location.href }
        });
      });
    }
  }

  function setUser(user) {
    window.coronadoAuth.user = user;
    renderWidget(user);
    document.dispatchEvent(new CustomEvent('coronado-auth-change', { detail: user }));
  }

  authClient.auth.getSession().then(({ data: { session } }) => setUser(session?.user || null));
  authClient.auth.onAuthStateChange((_event, session) => setUser(session?.user || null));
})();
