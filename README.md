# ISP Bill Collection — Cloud / Mobile Version

This version keeps the existing simple ISP billing UI but adds:

- Collector login from any mobile/desktop browser.
- Supabase Auth for Admin and Collector accounts.
- Shared cloud data instead of device-only data.
- Realtime sync: when a Collector records a payment, the Admin copy refreshes automatically.
- Customers, packages, collectors and payment records are stored in the cloud.
- GitHub Pages compatible — no backend server is required.

## 1. Create a Supabase project

Create a project at https://supabase.com/.

Then open **SQL Editor** and run `supabase.sql` from this folder.

In **Authentication → Providers → Email**, disable **Confirm email** if you want new Admin/Collector accounts to work immediately without email verification.

## 2. Add the Supabase keys

Open `config.js` and fill in:

```js
window.ISP_CLOUD_CONFIG = {
  url: "https://YOUR-PROJECT.supabase.co",
  anonKey: "YOUR-SUPABASE-ANON-PUBLIC-KEY"
};
```

Use the **anon/public** key only. Never use the `service_role`/secret key in this file.

## 3. Test locally

Keep these files in the same folder:

- `index.html`
- `config.js`

Open `index.html` in a browser. For the most reliable browser behavior, serve the folder with a simple local web server rather than opening it with `file://`.

## 4. Put it on GitHub Pages

Upload `index.html`, `config.js`, `supabase.sql`, and `README.md` to the root of a GitHub repository.

Then:

1. GitHub repository → **Settings**
2. **Pages**
3. Source: **Deploy from a branch**
4. Branch: `main`
5. Folder: `/ (root)`
6. Save

Your app will get a GitHub Pages address.

## 5. How Collector → Admin sync works

1. Admin creates a Collector from **Collectors → Add collector**.
2. Collector gets a username and password.
3. Collector opens the GitHub Pages link on their phone.
4. Collector chooses **Collector** login and signs in.
5. Collector records a payment.
6. The payment is saved in Supabase.
7. Supabase Realtime sends the change to the Admin browser.
8. Admin dashboard/payment/report data refreshes automatically.

### Important

This app uses a single shared JSON ledger per ISP company for the existing UI. The provided Row Level Security policies restrict access to authenticated members of the same company. The UI treats Admin and Collector as different roles, but the cloud data row is shared by company members.

For a larger production ISP, the next upgrade should split customers, bills and payments into separate database tables with stricter per-role write policies.

## Existing offline data

The old offline version stored data only in browser localStorage. This cloud version does not automatically migrate that old data. If you already have important offline records, keep the old backup before switching.

## PDF

Receipt/report PDF export still loads jsPDF from a CDN, so that specific feature needs internet access.
