# Changes

## 2026-01-05 v2.2.1

- Migrated all CI/CD pipelines from Ubuntu 20.04 to Ubuntu **24.04**
- Updated `gem_hadar` development dependency to **2.16.3** or higher
- Added `changelog` configuration to `Rakefile` to generate `CHANGES.md`
- Improved severity filtering
    - Improved robustness by using safe navigation operator
      (`&.`) when accessing `@opts[?S]`
    - Enhanced severity handling by explicitly converting severities into array
    - Ensured severity filtering works correctly even when no severity options are
      provided

## 2025-11-14 v2.2.0

- Updated `tins` runtime dependency from "~> 1.3" with ">= 1.22.0" to "~> 1.47"
- Modified `@opts[?F]` to `@opts[?F].to_a` in `betterlog` binary to ensure
  proper array handling
- Updated `gem_hadar` development dependency from version **1.28** to **2.8**
- Added `openssl-dev` to the list of packages installed via `apk add` in
  Dockerfile
- The change affects the `dockerfile` section in `.all_images.yml`

## 2025-09-04 v2.1.4

- Updated gem version to **2.1.4** across all relevant files
- Modified `VERSION` file to reflect new version **2.1.4**
- Updated `betterlog.gemspec` to use version **2.1.4** in gem specification
- Changed `lib/betterlog/version.rb` to set `VERSION` constant to **2.1.4**
- Completely rewrote `README.md` with comprehensive documentation

## 2025-09-03 v2.1.3

- Improved documentation for the `colorize` method with detailed styling examples
- Enhanced documentation for the `format_pattern` method with a detailed syntax guide
- Added `doc` directory to `.gitignore` and updated `Rakefile` to include it in the ignore list

## 2025-09-02 v2.1.2

- Moved only `filter_severities` method to private scope

## 2025-09-02 v2.1.1

- Set required Ruby version to ~> **3.2** in both `Rakefile` and
  `betterlog.gemspec`
- Added `.all_images.yml`, `.tool-versions`, `.gitignore`, and files under
  `.semaphore/` and `.github/` to package_ignore in `Rakefile`
- Added comprehensive documentation to the `Betterlog::App` class, including
  detailed class documentation, method documentation with parameters and return
  values, and improved code organization with comments
- Removed ruby version **3.1** from the image list in `.all_images.yml`
- Added `CHANGES.md` file to document project history and version updates

## 2025-09-02 v2.1.0

- Improved documentation and added comprehensive comments throughout Betterlog
  modules
- Updated Ruby version from **3.4.1** to **3.4.5** in tool versions
  configuration
- Removed metric deprecation warning.

## 2025-02-19 v2.0.6

- Added `licenses` attribute to GemHadar in Rakefile

## 2025-02-13 v2.0.5

- Removed `gem update --system` command from Dockerfile to prevent version
  changes
- Added `yaml-dev` package to `build-base` installation in Dockerfile
- Updated `gem install gem_hadar` command in Dockerfile to run without bundler
- Added support for Ruby versions **3.4** and **3.3** with new Docker image
  configurations
- Updated `.tool-versions` file to use Ruby version **3.4.1** and removed
  **2.3.17**

## 2024-03-13 v2.0.4

- Improved the legacy event formatter implementation
- Updated code to use the new name for the legacy event formatter

## 2024-03-13 v2.0.3

- Added global metadata support to the legacy emitter
- Renamed and moved the legacy formatter/emitter components
- Removed the passing of context to blocks in the code

## 2024-01-25 v2.0.2

- Removed the passing of context to block in the codebase
- Eliminated unnecessary context parameter handling in block execution flow

## 2023-08-17 v2.0.1

- Renamed `with_metadata` method to `with_meta`
- Added new `Betterlog.with_meth` convenience method
- Updated method names to improve clarity and consistency in logging
  functionality

## 2023-08-17 v2.0.0

- Removed obsolete metric support with warning implementation
- Simplified code significantly
- Added support for `Betterlog::GlobalMetadata` via block form of
  `with_context` method
- Updated `with_context` method to handle context variable removal properly
- Changed behavior to warn about removed metric support instead of maintaining
  it

## 2023-08-16 v1.1.1

- Added Sidekiq context to metadata of regularly emitted events
- Enhanced event metadata with Sidekiq information for better tracking and
  debugging capabilities

## 2023-02-10 v1.1.0

- Added context of Sidekiq logger to legacy emitter output
- Enhanced logging capabilities by incorporating Sidekiq context information
- Improved debugging and monitoring of legacy emitter functionality
- Updated logging infrastructure to support Sidekiq integration
- Modified emitter output format to include additional contextual information

## 2023-01-30 v1.0.0

- Removed the `log_pusher` functionality from the codebase
- Eliminated the associated logging mechanism that was previously used for
  pushing logs

## 2022-08-18 v0.20.3

- Added example code to demonstrate usage
- Updated build configuration to use Go version **1.17**
- Upgraded base image to Alpine **3.14.3**
- Removed deprecated `cloudbuild.yaml` file
- Implemented proper loading of version specification
- Configured CodeQL analysis workflow
- Reverted previous message-related changes
- Built project from scratch with updated dependencies
- Updated build system and tooling configurations

## 2021-10-28 v0.20.2

- Reverted previous changes that modified the behavior of passing arguments
- Changed implementation to rely on the originally passed argument instead of
  alternative approaches
- Removed modifications that had been previously introduced for argument
  handling

## 2021-10-28 v0.20.1

- Fixed backtrace parsing logic to handle edge cases properly
- Corrected backtrace parsing implementation for more reliable error reporting
- Improved backtrace parsing to work correctly with **Ruby** version **3.1**+
  error messages
- Enhanced backtrace parsing to properly extract method names and file
  locations from stack traces

## 2021-10-26 v0.20.0

- Modified message coloring behavior to remove colors from JSON output
- Updated test execution to continue running tests even when push operations
  fail

## 2021-09-21 v0.19.0

- Upgraded Ruby version to **3.0.2**
- Upgraded labstack/echo to specific v4 version
- Upgraded Alpine Linux to version **3.14.2**
- Upgraded Alpine Linux to version **3.14.1**
- Upgraded Alpine Linux to version **3.14**
- Upgraded Alpine Linux to version **3.13.5**
- Upgraded Alpine Linux to version **3.13.4**
- Implemented git SHA tagging for master commits

## 2021-03-05 v0.18.0

- Fixed compatibility issue with **Ruby 3.0**
- Updated version tag

## 2021-03-01 v0.17.0

- Updated base image to **alpine 3.13.2**

## 2021-02-10 v0.16.0

- Added check for tag name in the codebase
- Upgraded base system to Alpine version **3.13.1**

## 2021-02-03 v0.15.2

- Handle invalid UTF-8 characters in log messages
- Add bx configuration
- Add path configuration
- Pass registry name being used
- Upgrade dependencies
- Base image on alpine:**3.12.3**
- Only push on master branch builds

## 2020-12-07 v0.15.1

- Move testing configuration to Semaphore CI environment
- Improve search syntax implementation

## 2020-11-02 v0.15.0

- Added test configuration for Semaphore CI platform
- Updated continuous integration setup to include Semaphore testing environment
- Configured build pipeline to run tests on Semaphore infrastructure
- Integrated Semaphore-specific test execution settings

## 2020-08-26 v0.14.1

- Allow log file to be missing during loading process
- Handle cases where log file may not exist when loading configuration

## 2020-07-30 v0.14.0

- Fixed regexp encoding match problem
- Made log level easily configurable

## 2020-07-20 v0.13.1

- Replace existence check with boolean method
- Upgrade base image to Alpine **3.12.0**

## 2020-05-12 v0.13.0

- Updated base image to **alpine 3.11.6**
- Modified `kubectl` config name in `betterlog_sink` to use `cluster.name` from
  configuration instead of hardcoded value

## 2020-04-20 v0.12.2

- Added support for using `as_json` method for automatic serialization
- Enabled automatic serialization functionality when `as_json` is present

## 2020-04-02 v0.12.1

- Updated output handling to include **false** values in addition to previously
  handled values
- Modified the output logic to ensure boolean **false** is properly processed
  and displayed

## 2020-04-02 v0.12.0

- Added ability to evaluate block results and log with metric
- Implemented new functionality for block result evaluation
- Enhanced logging capabilities with metric support
- Updated code to support metric-based logging of block evaluations
- Modified evaluation logic to incorporate metric tracking
- Added logging infrastructure for block result metrics
- Improved block evaluation reporting with metric integration

## 2020-04-02 v0.11.0

- Simplified the interface by refactoring code structure
- Improved CLI command implementation for better usability
- Updated build configuration to target Alpine Linux version **3.11.5**
- Switched to using `better-builder` for enhanced build capabilities

## 2020-01-22 v0.10.0

- Handle intermittent redis failover events with liberal logging to a fallback
  logger
- Fallback to a standard stderr logger when redis has connection problems,
  particularly during failover events
- Mute output and use expect instead for improved behavior
- Improve output formatting
- Add support for testing on Ruby **2.7**
- Include Redis failover fixes
- Add `cloudbuild.yaml` configuration file

## 2020-01-17 v0.9.0

- Added support for using sentinel configuration for high availability Redis
  setups
- Included `error_class` in the pl (package list) command output format

## 2019-11-15 v0.8.1

- Fixed the output format of metrics in the `Metric` class
- Repurposed the `type` attribute to function as a metric identifier across all
  metrics
- Updated metric handling to use `metric` as the primary classification instead
  of `type`

## 2019-11-15 v0.8.0

- Changed the keyword arguments and semantics of the `Log.metric` method
- Updated the `Log.metric` method to support new parameter handling
- Modified how metric data is processed and stored within the logging system
- Adjusted internal logic for metric collection and reporting
- Enhanced flexibility in how metrics are configured and used throughout the
  application

## 2019-11-06 v0.7.2

- Prevented honeybadger notifier from modifying its argument, which caused
  circular reference issues
- Removed original hash from being passed to honeybadger as it corrupts the
  data structure
- Fixed circular reference problem in honeybadger integration by avoiding
  modification of notifier arguments
- Ensured honeybadger does not ruin the original hash by not passing it through
- Addressed issue where honeybadger was modifying its input argument causing
  unexpected behavior

## 2019-11-01 v0.7.1

- Fixed casing issues in the codebase
- Updated version number to **1.5.0**

## 2019-10-31 v0.7.0

- Allow configuration using `redis_url` directly by catching
  `Redis::CannotConnectError` to prevent application crashes and disable
  logging instead
- Implement flyweight pattern on `Betterlog::Log::Severity` constant wrapper
  for improved performance
- Add test for circular regression with repeated immediate objects
- Use `tins symbolize_keys_recursive` to handle circular data structures
- Fix clobbering of repeated scalar values in configuration
- Switch to using `go mod` for package management
- Add server and clients for logging functionality

## 2019-07-22 v0.6.1

- Made `maximum buffer_size` configurable through a new configuration option
- Added ability to customize the buffer size limit for data processing
  operations

## 2019-07-18 v0.6.0

- Updated implementation to actually perform the actions previously only
  announced
- Fixed discrepancy between declared functionality and actual code behavior
- Ensured proper execution of intended operations in the codebase

## 2019-07-18 v0.5.0

- Fixed implementation to actually perform the intended behavior as announced
  in previous commit
- Corrected logic to properly handle the expected functionality for **v3.5.0**
  release

## 2019-07-17 v0.4.0

- Added lock mechanism to `betterlog_pusher` to ensure the task runs only once,
  preventing issues during scalingo deployments where the task might start
  multiple times simultaneously
- Improved test specifications
- Added configuration hints for better user guidance
- Updated example `log.yml` configuration file
- Enhanced documentation with additional information

## 2019-07-15 v0.3.0

- Added `betterlog_sink` command and sink to path
- Updated dependency to use the newest version of `gem_hadar` **1.0.0**

## 2019-07-04 v0.2.2

- Added support for providing health page in disabled SSL mode
- Moved some code into separate files to improve organization
- Bumped version number to **0.15.0**

## 2019-06-27 v0.2.1

- Logger configuration still requires manual setup
- The `Logger` component needs explicit configuration rather than automatic
  initialization
- Users must manually configure the logger settings in their applications

## 2019-06-27 v0.2.0

  * Start
