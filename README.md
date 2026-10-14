# Next Step (prototype)

A consumer-first Flutter web prototype for credential-wallet workers. Three things a worker can do:

1. **My work** - add a job by picking what they actually did from a task list (instead of just typing a trade). Entries start as "Self-described". They only become "Confirmed" when a named supervisor confirms (demo only, nothing is sent).
2. **Pay** - what the trade typically pays in the US (national median), compared with other trades.
3. **Next step** - how people get into the trade, similar trades, and link-outs to Apprenticeship.gov and CareerOneStop.

Everything on screen is a fictional demo. No real accounts, credentials, employer data or private product data.

## Data

- O*NET 31.0 Database (task statements, occupation data, job zones, related occupations), bundled as `lib/data.dart`. CC BY 4.0, modified (selected and reordered). See NOTICE.md.
- US Bureau of Labor Statistics OEWS national estimates for 2025 (annual median, annual mean, employment), pulled once from the public BLS API and bundled. No API key at runtime.
- CareerOneStop and Apprenticeship.gov: link-outs only. No CareerOneStop API is used (it needs registration and approval).

Trades shown are illustrative, not BuilderFAX's actual trade mix.

## Run

    flutter create --platforms web --project-name worker_next_step .
    flutter pub get
    flutter run -d chrome
