**Manual Run**
1. ruby bin/run_smoke_test_insights_db.rb config/crunchy_env.conf
2. ruby bin/run_smoke_test_insights_db.rb config/heroku_env.conf
3. ruby bin/run_smoke_test_crunchy_analytics.rb config/crunchy_analytics_env.conf

**Crontab Setup Example (for Mac Users) **
1. */15 * * * * PATH=/opt/homebrew/bin:$PATH bash -l -c '/Users/nishitsoni/.rbenv/shims/ruby /Users/nishitsoni/Documents/code/perf-metrics/bin/run_smoke_test_insights_db.rb /Users/nishitsoni/Documents/code/perf-metrics/config/heroku_env.conf >> /Users/nishitsoni/Documents/code/perf-metrics/logs/smoke_test.log 2>&1'
2. */15 * * * * PATH=/opt/homebrew/bin:$PATH bash -l -c '/Users/nishitsoni/.rbenv/shims/ruby /Users/nishitsoni/Documents/code/perf-metrics/bin/run_smoke_test_insights_db.rb /Users/nishitsoni/Documents/code/perf-metrics/config/crunchy_env.conf >> /Users/nishitsoni/Documents/code/perf-metrics/logs/smoke_test.log 2>&1'