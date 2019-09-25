# betterlog

## Description

Logging tools for betterplace structured logging in rails applications.

## Configuration

Copy the example configuration in config/log.yml into your application to get
you started. Then add this line to your Gemfile:

```
gem 'betterlog'
```

## Usage

### `betterlog`

Use it to tail local logfiles:

```
$ betterlog -f
```

or filter from stdin with

```
$ cat log/development.log | betterlog
```

Search for GET in the last 1000 rails log lines:

```
$ betterlog -F rails -n 1000 -s GET
```

Display the help for more options with `betterlog -h`.

### `betterlog_pusher`

- `BETTERLOG_SERVER_URL` is the URL log information is ultimately posted to
  in the form of `https://user:password@appname-prd-log.betterops.de/log`.

- `BETTERLOG_LINES`, e. g. 1000, is the number of lines which are posted per
  every request to the above URL.

- `REDIS_URL` the redis server URL for the server where Log information is
  stored before posted to the betterlog server.

  The rails application should be configured like this to store log information
  on this redis server:

  ```
  config.logger = Betterlog::Logger.new(Redis.new(url: ENV.fetch('REDIS_URL')))
  ```

### `betterlog_sink`

This is a small wrapper around the `kubectl logs…` command,
see `kubectl help logs` for the options.

To tail a log and prettify the output just call and pipe to the `betterlog`
executable:

```
$ betterlog_sink --since=1m -f | betterlog
```

The sink always defaults to the production logfile, to switch the context to
staging, prepend the command with the `LOG_ENV` env variable like so:

```
$ LOG_ENV=staging betterlog_sink -f | betterlog
```
