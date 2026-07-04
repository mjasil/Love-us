# Knot 💞

A private space for two. Locket-style photo drops to your partner's home screen, realtime chat, and countdowns. Flutter + Supabase. Built to be deployed 100% from a phone.

## Features (MVP)

- Pair with your partner via a 6-letter invite code
- **Drops** — snap a photo, it appears on their feed + home-screen widget
- **Chat** — realtime, private, just the two of you
- **Days** — days-together counter + custom countdowns (anniversary, trips)
- Android home-screen widget included; iOS WidgetKit file included (`native/ios/KnotWidget.swift`)

## Setup (all from mobile)

### 1. Supabase (5 min)

1. Create a project at supabase.com (free)
2. SQL Editor → paste and run all of `supabase/schema.sql`
3. Storage → New bucket → name it `drops`, set **Public**
4. Project Settings → API → copy the URL and anon key
5. Edit `lib/main.dart` lines 8–9 with those values

### 2. Android APK (free, GitHub Actions)

1. Push this repo to GitHub
2. Actions tab → "Build Android APK" runs automatically on push
3. Download `knot-release-apk` artifact → install on both phones

The workflow runs `flutter create .` itself, so this repo only needs `lib/`, `native/`, `scripts/`, and the configs — nothing to generate locally.

### 3. iOS (Codemagic)

1. Sign in at codemagic.io with GitHub → add this repo
2. It picks up `codemagic.yaml` and builds an unsigned .ipa on the free tier
3. To install on a real iPhone: Apple Developer account ($99/yr) + code signing in Codemagic, or use their TestFlight publishing
4. iOS widget: add a Widget Extension target named `KnotWidget` with App Group `group.com.flovex.knot`, drop in `native/ios/KnotWidget.swift`

## Roadmap ideas

- Push notifications on new drops (FCM) so partner's widget refreshes instantly
- Photo reactions / captions
- Shared bucket list (port from TwoUs)
- "Missing you" tap that buzzes their phone

## Structure

```
lib/            Flutter app (screens, theme, main)
native/android  Widget provider + layouts (wired in CI)
native/ios      WidgetKit widget (add via Xcode target)
supabase/       Full DB schema with RLS
scripts/        CI helper to patch AndroidManifest
```
