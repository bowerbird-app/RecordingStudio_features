# Dummy App

This Rails app exists to validate the features catalogue in a real host application.

## What It Covers

- Devise authentication with a seeded admin user
- An Admin root with a Features section, plus workspace, folder, and page recordables
- Recording Studio default layout, FlatPack assets, and Tailwind source scanning
- Mounted Attachable, API, and Features engines
- A named `catalogue` API whose access point is the Admin root
- Dummy-only `/docs/*` pages for gem-specific onboarding

## Quick Start

```bash
cd test/dummy
bundle install
bin/rails db:setup
bin/dev
```

Run the commands above from the dummy app directory, not the repository root.

Then open the app and sign in with:

- Email: `admin@admin.com`
- Password: `Password`

## Useful Routes

- `/` redirects unauthenticated visitors to sign-in. After sign-in it links to Features.
- `/recording_studio` redirects to `/` while the mounted Recording Studio engine stays available under that prefix for non-root routes
- `/admin/screens/recording_studio_features` lists features for the current root. Switch the root to Admin.
- `/recording_studio_features/admin/features/new` creates a feature
- `/recording_studio_api/apis/catalogue/v1/features` is the named API
- `/users/sign_in` is the Devise sign-in page
- `/docs/install`, `/docs/config`, `/docs/recordable_types`, `/docs/recordings_tree`, `/docs/gem_views`, `/docs/methods` are dummy-only starter pages
- `/up` is the Rails health check

## Why This App Exists

Use this app to exercise the catalogue under an Admin root, including the admin list, image attachment, and named API. Authenticated pages use Recording Studio's shared default layout. Devise sign-in keeps `layouts/application`.

The home page stays a short link into Features. Longer notes stay in the gem README.
