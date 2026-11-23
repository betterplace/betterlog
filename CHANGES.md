# Changes

## 2026-11-20 v2.5.0

### Improvements
- Widened the `json` dependency constraint from `~> 2.0` to `>= 2.0, < 4`
  to allow compatibility with `json` **3.x**.
- Removed the unused `redlock` runtime dependency from `Rakefile` and
  `betterlog.gemspec`.

## 2026-11-20 v2.4.0

### Fixes
- Corrected YARD documentation accuracy across multiple files,
  including removing the `@return [ void ]` tag from
  `Betterlog::GlobalMetadata#remove`, broadening the `@return` for
  `Betterlog::Log::Event.is?`, and updating parameter documentation for
  `Betterlog::Log::Event.ify` and `Betterlog::Log` methods to use
  specific `@option` tags.
- Escaped braces in `Betterlog::Log::EventFormatter#colorize`
  documentation to prevent misparsing of log-format DSL syntax.
- Updated `Betterlog::Notifiers.notify` documentation to accurately
  reflect the implementation.

### Improvements
- Optimized `Betterlog::Notifiers.notify` to serialize event JSON once
  and hoist context setting out of the notifier loop, reducing
  complexity from O(N²) to O(N).
- Removed dead code `Betterlog::Log#build_metric`.

### Build & CI
- Updated Ruby version from **3.4.8** to **3.4.13** in `.tool-versions`
  to include recent security advisories and memory-safety fixes.
- Updated `gem_hadar` development dependency constraint from
  **>= 2.16.3** to **>= 2.24.1** in `betterlog.gemspec`.
- Regenerated `lib/betterlog/version.rb`, `Gemfile`, and `Rakefile` via
  `gem_hadar`, removing stale vim modeline comments.
- Updated ignore patterns in `Rakefile` and `.gitignore` to replace
  `betterlog-server` and `gospace` with `cscope.out`.

## 2026-01-08 v2.3.0

### Features
- Added support for Ruby **4.0-alpine** to the CI matrix.
- Changed `required_ruby_version` from `~> 3.2` to `>= 3.2` in
  `Rakefile` and `betterlog.gemspec`.

### Build & CI
- Added `readline-dev` to the Dockerfile for readline support.
- Replaced `bundle` and `rake spec` with `bundle update --all`,
  `bundle install`, and `bundle exec rake spec` in `.all_images.yml`.
- Updated `Gemfile` to use `>= 3.2` for `required_ruby_version`.

## 2026-01-05 v2.2.1

### Improvements
- Improved severity filtering by using the safe navigation operator
  (`&.`) when accessing `@opts[?S]`.
- Enhanced severity handling by explicitly converting severities into an
  array using `.to_a`.

### Build & CI
- Migrated all CI/CD pipelines from Ubuntu 20.04 to Ubuntu **24.04**.
- Updated the `gem_hadar` development dependency to **2.16.3** or higher.
- Added `changelog` configuration to the `Rakefile` to generate
  `CHANGES.md`.

### Documentation
- Added a new entry for version **2.2.1** to `CHANGES.md`.

## 2025-11-14 v2.2.0

### Features
- Updated the `tins` runtime dependency from `~> 1.3` with
  `>= 1.22.0` to `~> 1.47` in `Rakefile` and
  `betterlog.gemspec`.

### Fixes
- Modified `@opts[?F]` to `@opts[?F].to_a` in the `betterlog`
  binary to ensure proper array handling.

### Build & CI
- Updated the `gem_hadar` development dependency from version
  **1.28** to **2.8** in `betterlog.gemspec`.
- Added `openssl-dev` to the list of packages installed via
  `apk add` in the Dockerfile within `.all_images.yml`.

## 2025-09-04 v2.1.4

### Documentation

- Completely rewrote `README.md` with comprehensive documentation, including
  installation, usage, CLI options, architecture, configuration, and Rails
  integration.
- Updated copyright notice in `LICENSE` from `Florian Frank` to
  `betterplace`.

## 2025-09-03 v2.1.3

### Build & CI
- Added the `doc` directory to `.gitignore` and the `Rakefile`
  ignore list, and removed `errors.lst` from the `Rakefile` ignore
  list.

### Documentation
- Improved documentation for the `colorize` method in
  `lib/betterlog/log/event_formatter.rb` with detailed styling
  examples.
- Enhanced documentation for the `format_pattern` method with a
  detailed syntax guide.

## 2025-09-02 v2.1.2

### Fixes
- Moved the `filter_severities` method to private scope

## 2025-09-02 v2.1.1

### Breaking
- Set required Ruby version to ~> **3.2** in both `Rakefile` and
  `betterlog.gemspec`.
- Removed support for Ruby version **3.1** in the docker image
  configuration.

### Documentation
- Added comprehensive documentation to the `Betterlog::App` class, including
  detailed class and method documentation.
- Added a new `CHANGES.md` file to document project history.

### Build & CI
- Added `.all_images.yml`, `.tool-versions`, `.gitignore`, and files under
  `.semaphore/` and `.github/` to `package_ignore` in `Rakefile`.
- Added `CHANGES.md` to the list of files in the gemspec.

## 2025-09-02 v2.1.0

### Documentation
- Added comprehensive comments to `Betterlog` module and
  `GlobalMetadata` class methods, including `add`, `remove`, and
  `with_meta`.
- Documented public and private methods for `Betterlog::Log`, including
  `info`, `warn`, `debug`, `error`, `fatal`, `output`, and `emit`.
- Added YARD documentation to `Betterlog::Log::Event` methods such as
  `ify`, `parse`, `is?`, `initialize`, `as_json`, `to_json`, `format`,
  `severity`, `emitter`, `notify?`, `eql?`, `hash`, and `compute_data`.
- Included documentation for `Betterlog::Log::EventFormatter` methods,
  including `initialize`, `format`, `colorize`, `apply_style`,
  `format_pattern`, and `format_object`.
- Documented `Betterlog::Log::LegacyEventFormatter` and
  `Betterlog::Log::Severity` classes, covering their constructors,
  conversion methods, and comparison logic.
- Added class-level and method documentation to
  `Betterlog::Notifiers`, including `register`, `notify`, and
  `context`.
- Documented the `Betterlog::Railtie` integration and the `Log`
  convenience alias class in `lib/betterlog.rb`.

### Build & CI
- Updated `gem_hadar` development dependency constraint from `~> 1.19`
  to `~> 1.28`.
- Replaced direct `simplecov` configuration in `spec/spec_helper.rb`
  with `gem_hadar/simplecov` initialization.
- Updated the Ruby version in `.tool-versions` from **3.4.1** to
  **3.4.5**.

## 2025-02-19 v2.0.6

### Build & CI
- Added `Apache-2.0` license metadata to the `Rakefile` and
  `betterlog.gemspec` for RubyGems packaging.

## 2025-02-13 v2.0.5

### Improvements
- Add support for Ruby **3.3** and **3.4** in CI configurations
  by adding `ruby:3.3-alpine` and `ruby:3.4-alpine` images.

### Build & CI
- Update `.tool-versions` to use Ruby **3.4.1** and remove the
  `bundler` version pinning.
- Update Dockerfile to install `yaml-dev` and `gem_hadar`, while
  removing the `gem update --system` step and `bundler` installation.

## 2024-03-13 v2.0.4

### Improvements
- Improved the legacy event formatter by updating its reference to use
  the renamed `Betterlog::Log::LegacyEventFormatter` class.

### Testing
- Renamed the event formatter spec file to
  `spec/betterlog/log/legacy_event_formatter_spec.rb` to align with the
  updated module structure.

## 2024-03-13 v2.0.3

### Breaking
- `GlobalMetadata.with_meta` no longer passes a frozen context object to the
  block; the block must now rely on `GlobalMetadata.current` to access the
  active metadata.

### Features
- The legacy event emitter now includes global metadata from
  `GlobalMetadata` instead of manually reading `Sidekiq::Context`.

### Improvements
- Renamed `LogEventFormatter` to `LegacyEventFormatter` and moved it to
  `lib/betterlog/log/legacy_event_formatter.rb` for better namespace
  organization.

## 2024-01-25 v2.0.2

### Breaking
- Removed the metadata context hash argument from the block passed to
  `with_meta` in `Betterlog::GlobalMetadata`.

### Testing
- Updated `spec/betterlog/global_metadata_spec.rb` to remove assertions
  for the removed block argument.

## 2023-08-17 v2.0.1

### Breaking
- Renamed `Betterlog::GlobalMetadata.with_context`
  to `Betterlog::GlobalMetadata.with_meta`.

### Features
- Added `Betterlog.with_meta` as a convenience method
  for managing global metadata.

### Testing
- Updated global metadata specs to use the renamed
  `with_meta` method.
- Added tests to verify the new `Betterlog.with_meta`
  shortcut method.

## 2023-08-17 v2.0.0

### Breaking
- Removed support for `Log#metric`, which now emits a deprecation warning.
- Replaced `Log#context` with the `Betterlog::GlobalMetadata#with_context` block form for automatic context cleanup.
- Changed the interface of `Betterlog::Notifiers.notify` to accept a message and event data.

### Features
- Added `Betterlog::GlobalMetadata#remove` to clear specific keys from the global context.
- Added `Betterlog::GlobalMetadata#with_context` to manage context variables within a block.

### Improvements
- Simplified `Log::Event.ify` to use keyword arguments and consistent data handling.
- Updated `Betterlog::GlobalMetadata` to store data in a thread-local `current` hash.
- Refactored `Log` methods to merge severity into the event data consistently.
- Updated `Log::Event` to nest global metadata and Sidekiq context under a `meta` key.

### Build & CI
- Added `all_images` configuration for testing against Ruby **3.1** and **3.2** Alpine images.
- Added `debug` and `all_images` as development dependencies in the Rakefile and gemspec.

### Testing
- Added test coverage for `Betterlog::GlobalMetadata` add, remove, and with_context behaviors.
- Updated log event specs to verify metadata inclusion in notification payloads.
- Replaced `byebug` with `debug` in the test helper.

## 2023-08-16 v1.1.1

### Features
- Include `Sidekiq::Context.current` in the `meta` data for events emitted by the library.

## 2023-02-10 v1.1.0

### Features
- Include `Sidekiq::Context.current` metadata in legacy log event
  output when `Sidekiq` is defined.
- Symbolize keys recursively in `GlobalMetadata#add` data hash.

## 2023-01-30 v1.0.0

### Breaking
- Removed `betterlog_pusher` and `betterlog_sink` executables.
- Removed the `Betterlog::Logger` class and its `redis` runtime dependency.

### Build & CI
- Removed the Go build toolchain, `Dockerfile`, and associated CI tasks.
- Updated gem metadata to reflect the removal of `redis` and `mock_redis` dependencies.

## 2022-08-18 v0.20.3

### Breaking
- The Docker image now runs the `betterlog-server` binary directly from the
  root directory and no longer uses `go-init` as the entrypoint.

### Features
- Added a CodeQL analysis workflow to scan Go and Ruby code on pushes,
  pull requests, and a weekly schedule.

### Improvements
- Refactored the Dockerfile to use a `golang:1.18-alpine` base image,
  enabling a scratch-based final image for reduced size and security
  surface.
- Upgraded the Go toolchain to version **1.19** and updated dependencies,
  including `github.com/labstack/echo/v4` to version **4.8.0**.
- Updated `.tool-versions` to specify Ruby **3.1.2** and Golang **1.19**.

### Build & CI
- Removed the `cloudbuild.yaml` configuration file, replacing the previous
  build pipeline with the new Docker and GitHub Actions setup.
- Updated the development dependency on `gem_hadar` to version **1.12.0**.

### Testing
- Refactored `global_metadata_spec.rb` to use a named `FakeNotifierClass`
  instead of an anonymous class.
- Added a version spec to ensure `Betterlog::VERSION` is a valid string.

### Documentation
- Added usage examples for matching specific events and metadata in the
  `bin/betterlog` help text.

## 2021-10-28 v0.20.2

### Fixes
- Reverted a change in `LogEventFormatter#call` that
  incorrectly overwrote the `message` argument with the result of
  `super.to_s`.

## 2021-10-28 v0.20.1

### Fixes
- Corrected the regex used by `log_event_formatter.rb` to properly
  parse backtrace lines from log messages.

## 2021-10-26 v0.20.0

### Features
- Strip ANSI color codes from non-event log messages before
  serialization to ensure clean JSON output.

### Fixes
- Set the `message` attribute to the first line of the backtrace
  instead of a static string when logging multi-line backtraces.

### Build & CI
- Update the CI environment from `ubuntu1804` to `ubuntu2004`.
- Dynamically determine the Ruby version from `.tool-versions`
  in CI pipelines instead of using a hardcoded version.
- Prevent CI build failures by allowing the image push step to
  exit successfully even if the push command fails.

### Testing
- Add `spec/betterlog/log_event_formatter_spec.rb` to cover
  message uncoloring, blank message handling, and backtrace
  deconstruction.

## 2021-09-21 v0.19.0

### Fixes
- Updated `Log::Event.ify` call in specs to pass an explicit hash
  literal to ensure Ruby 3 compatibility.

### Improvements
- Upgraded the `labstack/echo` dependency from version **v3** to
  **v4**.
- Upgraded the base Docker image to `alpine:3.14.2`.

### Build & CI
- Added `.tool-versions` to specify Go `1.16` and Ruby `3.0.2`.
- Configured the Semaphore CI pipeline to push the latest image
  for `master` branch commits instead of tagged releases only.
- Updated `docker build` commands in the Makefile to include the
  `--pull` flag.

## 2021-03-05 v0.18.0

### Fixes
- Fixed `format` method in `lib/betterlog/log/event.rb` to
  use keyword arguments for Ruby **3.0** compatibility.

## 2021-03-01 v0.17.0

### Build & CI
- Updated the base image from `alpine:3.13.1` to `alpine:3.13.2`.

## 2021-02-10 v0.16.0

### Build & CI
- Check `$SEMAPHORE_GIT_TAG_NAME` instead of branch to trigger
  `push-latest` in the Semaphore CI pipeline.
- Upgrade the base image from `alpine:3.12.3` to `alpine:3.13.1` in
  the `Dockerfile`.

## 2021-02-03 v0.15.2

### Fixes
- Handle invalid UTF-8 characters in log messages by sanitizing them to
  prevent serialization errors in `Log::Event#to_json`.
- Replace `Event#to_json` with `JSON.generate` in `Log`,
  `LogEventFormatter`, and `EventFormatter` for consistent and safe
  serialization of event data.

### Build & CI
- Configure Bundler to install gems into the `vendor/bundle` path in CI.
- Update Docker base image from **3.12.1** to **3.12.3**.
- Push Docker images to the `eu.gcr.io` registry.
- Restrict Docker image pushes to the `master` branch.
- Execute RSpec tests using `bundle exec` in CI.

## 2020-12-07 v0.15.1

### Improvements
- Updated the search logic in `bin/betterlog` to support
  nested key-value matching and direct string inclusion.

### Build & CI
- Migrated the continuous integration pipeline from Travis CI
  to Semaphore.

## 2020-11-02 v0.15.0

### Breaking
- Removed the `Redis` dependency from the `Rakefile` and replaced
  it with `mock_redis` in development and testing environments.

### Improvements
- Refactored library loading to require `logger`, `time`, and
  `term/ansicolor` within specific modules rather than globally.
- Updated `Dockerfile` to use `alpine:3.12.1` and renamed the
  `fetch` make target to `setup`.

### Build & CI
- Migrated CI infrastructure from Travis CI to Semaphore,
  removing `.travis.yml` and adding `.semaphore/semaphore.yml`.
- Added `mock_redis` as a development dependency in the
  gemspec.

### Testing
- Configured `mock_redis` in `spec/spec_helper.rb` to
  replace the global `Redis` constant during tests.

## 2020-08-26 v0.14.1

### Fixes
- Prevent errors during initialization if the log file is missing by
  using safe navigation to check the log level.

## 2020-07-30 v0.14.0

### Breaking
- The `logger` method in `Betterlog::Log` now delegates to `default_logger`
  instead of instantiating a new `::Logger` instance, which may change
  behavior for custom configurations.

### Fixes
- Fix a regexp encoding mismatch in `Betterlog::Logger#each` by
  forcing the buffer and regex to `ASCII-8BIT` encoding.
- Force encoding to `ASCII-8BIT` on Redis string ranges in
  `Betterlog::Logger#each_chunk` to prevent encoding errors.

### Improvements
- Make log level configurable via `ComplexConfig` for both
  `Betterlog::Logger` and `Betterlog::Log`.

## 2020-07-20 v0.13.1

### Fixes
- Replace the deprecated `exists` method with `exists?` for Redis
  key lookups.

### Build & CI
- Upgrade the Docker base image to **3.12.0** from **3.11.6**.

## 2020-05-12 v0.13.0

### Features
- Use `cluster.name` from config for the `kubectl`
  config name in `betterlog_sink`.

### Build & CI
- Base the Docker image on `alpine:3.11.6` and remove the
  `BASE_IMAGE` build argument.

## 2020-04-20 v0.12.2

### Features
- Rename `as_hash` to `as_json` on `Betterlog::Log::Event` to
  indicate serialization intent, and update `to_json` to use the new
  method.
- Update `emit` in `Betterlog::Log` to use `as_json` instead of
  `as_hash` when constructing error context.
- Update `Betterlog::Notifiers` to pass `as_json` to registered
  notifiers.
- Make `emit` a public method on `Betterlog::Log` to allow external
  callers to trigger event emission.

### Documentation
- Update spec for `Betterlog::Log::Event` to test the renamed
  `as_json` method.

## 2020-04-02 v0.12.1

### Fixes
- Ensure that `false` values are correctly formatted in the event
  formatter output.

## 2020-04-02 v0.12.0

### Features
- Add optional `success` parameter to `metric`, allowing callers to
  evaluate block results and conditionally log success status.
- Modify `metric` to capture block results and pass them to the success
  block when building the event.

### Fixes
- Update specs to include `success` in expected events, ensuring default
  behavior is tested and custom success blocks validate correctly.

## 2020-04-02 v0.11.0

### Breaking
- Removed the `measure` method from `Log`, which was merged into
  `metric`.
- Updated the `metric` method to accept a block for timing, replacing
  the previous `measure` implementation.
- The `metric` method now sets `duration` in the event if a block was
  provided.
- Changed `time_block` to accept an optional block, returning
  immediately if no block is given.

### Features
- Added support for multiple `-s` search strings in the CLI, allowing
  users to filter events by multiple conditions simultaneously.
- Added support for JSON output format via `-p json` or `-p j` flags in
  the CLI.

### Improvements
- Refactored the `metric` method to handle both static values and timed
  blocks, simplifying the interface.
- Updated the CLI help text to reflect that the `-s` flag can be
  repeated.

### Build & CI
- Updated `go.mod` to use Go **1.14** and bumped `go-redis/redis` to
  **v6.15.7+incompatible**.
- Replaced the Docker builder in `cloudbuild.yaml` with
  `eu.gcr.io/betterplace-183212/better-builder`.

### Testing
- Merged `#measure` and `#metric` test cases into a single `#metric`
  block.
- Updated existing timing tests to use `metric` instead of `measure`.

## 2020-01-22 v0.10.0

### Features
- Fall back to a standard stderr logger if Redis has connection
  problems during failover events.
- Handle intermittent Redis failover events by cleaning up temporary
  keys and logging errors to the fallback logger.

### Fixes
- Correctly log the warning about reaching the Redis memory limit to
  the fallback logger instead of appending it to Redis.
- Ensure temporary Redis keys are deleted if the `each_chunk` process
  is interrupted or fails, preventing stale key accumulation.

### Improvements
- Update the `betterlog_pusher` output format to display a cleaner
  progress indicator and completion message.

### Build & CI
- Add `cloudbuild.yaml` for Cloud Build integration and update the
  Makefile to use Alpine 3.13.3 as the base image.
- Update the gemspec to include the new `cloudbuild.yaml` file in the
  package.

### Testing
- Add tests for the Redis failover fallback behavior in both `<<` and
  `add` methods.
- Update `log_spec` to mute specific logger output and expect standard
  logger interactions.
- Add Ruby **2.7** to the Travis CI test matrix.

## 2020-01-17 v0.9.0

### Features
- Use Redis Sentinel support in `bin/betterlog_pusher` when the
  `REDIS_SENTINELS` environment variable is set.
- Include the `error_class` variable in the plain output format defined
  in `config/log.yml`.

### Build & CI
- Bumped the `redis` gem dependency requirement to **2.8**.

## 2019-11-15 v0.8.1

### Breaking
- Removed the `type:` keyword argument from `metric` and `measure`,
  as the metric type is now automatically set to `metric` and the
  specific type is expected to be part of the metric `name`.

### Fixes
- Corrected the output of metrics by removing the `type` placeholder
  from the default metric format in `config/log.yml`.

### Improvements
- Updated `build_metric` to set a default severity of `info` instead of
  `debug`.
- Changed the default metric message format in `build_metric` to
  display the metric name and value pair, e.g., `a metric
  name=value`.

### Testing
- Updated unit tests in `spec/betterlog/log_spec.rb` to reflect the
  removal of the `type:` argument and the updated event structure.

## 2019-11-15 v0.8.0

### Breaking
- Renamed `metric` keyword argument to `name` in `Log#metric`,
  `Log#measure`, and `Log#build_metric`.
- Changed default metric `type` for `Log#measure` from `seconds`
  to `duration`.
- Modified `Log#logger` to check `Rails.respond_to?(:logger)`
  before accessing `Rails.logger`.

### Improvements
- Expanded documentation for `Log#metric` to clarify the usage
  and structure of the `name`, `type`, and `value` parameters.

## 2019-11-06 v0.7.2

### Fixes
- Return a dup of `@data` in `Betterlog::Log::Event#as_hash` to
  prevent Honeybadger from mutating the original hash.

### Testing
- Add a spec verifying that `Betterlog::Log::Event#as_hash` returns
  a new hash object rather than the internal instance variable.

## 2019-11-01 v0.7.1

### Fixes
- Corrected the casing of log severity names to lowercase and updated
  serialization output.
- Modified `Severity#as_json` to return the string representation,
  ensuring uppercase log levels.
- Updated the default unknown severity name to `:unknown`.

## 2019-10-31 v0.7.0

### Features
- Added `for_redis_url` class method to `Betterlog::Logger` to
  initialize a logger from a Redis URL, returning `nil` if the
  connection fails.
- Replaced custom circular reference detection in
  `Betterlog::Log::Event` with `tins`
  `symbolize_keys_recursive` using the `circular` option.

### Fixes
- Corrected `Betterlog::Log::Severity` to use uppercase symbols and
  implement the flyweight pattern for constant instances.
- Fixed `Betterlog::Log::Severity` comparison logic to properly
  handle comparisons with non-`Severity` objects.
- Resolved issue in `Betterlog::Log::Event` serialization where
  repeated scalar values were incorrectly flagged as circular.

### Improvements
- Switched Go module management to `go mod` in the `Makefile` and
  added `go.mod` and `go.sum` files.

### Testing
- Added `spec/betterlog/log/severity_spec.rb` to test
  `Betterlog::Log::Severity` behavior.
- Expanded `spec/betterlog/log/event_spec.rb` to cover circular hash
  handling and repeated scalar serialization.
- Added tests for `Betterlog::Logger.for_redis_url` connection
  handling in `spec/betterlog/logger_spec.rb`.

### Build & CI
- Updated `tins` dependency requirement to `>= 1.22.0`.

## 2019-07-22 v0.6.1

### Features
- Added configurable `buffer_size` option to `Betterlog::Logger`,
  which is now clamped between 1 MB and 511 MB.

## 2019-07-18 v0.6.0

### Fixes

- Removed immediate exit on `Redlock::LockError` in `bin/betterlog_pusher` to
  allow the retry loop to continue.

## 2019-07-18 v0.5.0

### Fixes
- Removed the call to `exit` in `bin/betterlog_pusher` when
  catching `Redlock::LockError` so the loop continues retrying

## 2019-07-17 v0.4.0

### Improvements
- Added `Redlock` support to `betterlog_pusher` to ensure the task runs
  only once.
- Added `host` to the default log format and metadata in `config/log.yml`.
- Updated staging and production log configurations in `config/log.yml` to
  include specific sink and cluster details.

### Documentation
- Added a new Configuration section to the README with setup instructions.
- Expanded the README with usage examples for `betterlog` and `betterlog_pusher`.

### Testing
- Updated `log_spec.rb` to include backtrace data and verify the inspected
  error message format.

## 2019-07-15 v0.3.0

### Features
- Added the `betterlog_sink` executable. This tool wraps `kubectl logs`
  to retrieve and format logs from the specified Kubernetes
  environment, with support for the `LOG_ENV` variable.
- Documented the usage of the new `betterlog_sink` command in the
  `README.md`.

### Build & CI
- Bumped the `gem_hadar` dependency to **~> 1.10.0**.
- Registered `betterlog_sink` in the `Rakefile` and `betterlog.gemspec`
  to ensure it is included in the package.

## 2019-07-04 v0.2.2

### Fixes
- Serve the health check page when SSL is disabled.

### Improvements
- Extract the `Config` and `RedisCertCache` types into dedicated
  files within the `betterlog` package.
- Correct the package declaration in `healthz.go` to `betterlog`.

## 2019-06-27 v0.2.1

### Improvements
- Removed the automatic assignment of `Rails.logger` to a `Betterlog::Logger`
  instance inside the railtie initializer, requiring manual configuration.

## 2019-06-27 v0.2.0

  * Start
