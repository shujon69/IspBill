# ISP App Online Setup — সহজ বাংলা গাইড

এই ভার্সনে Collector নিজের মোবাইল থেকে Login করতে পারবে এবং Payment Collect করলে Admin-এর Dashboard-এ Cloud থেকে data update হবে।

## যা লাগবে

1. একটি Supabase account/project
2. GitHub account/repository
3. এই folder-এর সব file

## Supabase

Supabase project বানানোর পর:

- SQL Editor খুলুন
- `supabase.sql` পুরোটা Run করুন
- Authentication → Providers → Email এ গিয়ে **Confirm email** বন্ধ করুন, যদি নতুন account সঙ্গে সঙ্গে login করাতে চান।

## config.js

`config.js` খুলে Supabase-এর:

- Project URL
- anon/public key

বসান।

**service_role/secret key কখনো `config.js`-এ দেবেন না।**

## GitHub

Repository root-এ এগুলো রাখুন:

- `index.html`
- `config.js`
- `supabase.sql`
- `README.md`
- `SETUP-BANGLA.md`

তারপর GitHub → Settings → Pages → Deploy from branch → `main` → `/ (root)` → Save।

## ব্যবহার

Admin:
- প্রথমে company account তৈরি করবেন।
- তারপর Collectors → Add collector থেকে collector username/password বানাবেন।

Collector:
- মোবাইল থেকে GitHub Pages link খুলবে।
- Collector tab নির্বাচন করবে।
- Username/password দিয়ে login করবে।
- Payment collect করবে।

Admin:
- Collector payment save করার পর cloud realtime sync-এর মাধ্যমে Admin browser-এ data update হবে।

## গুরুত্বপূর্ণ

পুরনো Offline version-এর data automatically cloud-এ যাবে না। পুরনো data থাকলে আগে backup রাখুন।

এই version-এ existing simple UI ধরে cloud sync যোগ করা হয়েছে। বড় ISP-এর জন্য পরে Customers/Bills/Payments আলাদা database table এবং আরও strict role-based permissions করা ভালো।
