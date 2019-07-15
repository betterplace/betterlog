# betterlog

## Description

Logging tools for betterplace structured logging

## Usage

### `betterlog`

TODO

### `betterlog_pusher`

TODO

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
