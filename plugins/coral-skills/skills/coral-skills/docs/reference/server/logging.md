# Logging

Source: https://docs.coralos.ai/reference/server/logging

# Log buffer size
**default** `32768`

- Command line: `--logging.log-buffer-size=1000`
- Config file: `logging.log_buffer_size = 1000`

The maximum number of log entries to keep in memory. This buffer is used for all log messages, including those sent by
agents. Note that the Coral console log view for an agent only applies a filter to the log buffer, so, if you desire
1000 log entries per agent, the buffer must be `1000` x `number of agents` + extra for system log entries.

Consider adjusting this value only after you experience loss of log entries in the Coral console.

# Max replay
**default** `2048`

- Command line: `--logging.max-replay=1000`
- Config file: `logging.max_replay = 1000`

The maximum number of log entries that will be sent to a new subscriber. Note that opening a Coral console agent log
view counts as a new subscription; this value caps the number of messages that appear in that view.

# Console log level
**default** `INFO`

- Command line: `--logging.console-log-level="TRACE"`
- Config file: `logging.console_log_level = "TRACE"`

The maximum log level that will be printed to the server's console.

Valid values, in order of increasing verbosity:
- `ERROR`
- `WARN`
- `INFO`
- `DEBUG`
- `TRACE`

# File log level
**default** `INFO`

- Command line: `--logging.file-log-level="TRACE"`
- Config file: `logging.file_log_level = "TRACE"`

The maximum log level that will be printed to the disk. Note [enable file logging](#enable-file-logging) must be true to
write any messages to disk.

Valid values, in order of increasing verbosity:
- `ERROR`
- `WARN`
- `INFO`
- `DEBUG`
- `TRACE`

# Enable file logging
**default** `true`

- Command line: `--logging.log-to-file-enabled=false`
- Config file: `logging.log_to_file_enabled = false`

If this is true, log messages will be written to a file on disk. The directory, number of log files, log file size and
other file logging options are further configurable using:
- [Log files directory](#log-files-directory)
- [Log file name](#log-file-name)
- [Log file name pattern](#log-file-pattern)
- [Max history](#max-history)
- [Log total size cap](#log-total-size-cap)
- [Clear log files on server start](#clear-log-files-on-server-start)
- [Max file size](#max-file-size)
- [File log level](#file-log-level)

# Log files directory
**default** `${HOME}/.coral/logs`

- Command line: `--logging.log-files-directory="/var/log/coral"`
- Config file: `logging.log_files_directory = "/var/log/coral"`

The directory where log files will be written. Note that the full path to a given log file may be different from the
value of this setting, see:
- [Log file name](#log-file-name)
- [Log file name pattern](#log-file-pattern)

# Log file name
**default** `${logFilesDirectory}/server.log`

- Command line: `--logging.log-file-name="/var/log/coral/server.log"`
- Config file: `logging.log_file_name = "/var/log/coral/server.log"`

The full path to the log file.  Read more [here](https://logback.qos.ch/manual/appenders.html#fileAppenderFile).

# Log file name pattern
**default** `${logFilesDirectory}/archive/%d{yyyy/MM, aux}/%d{yyyy-MM-dd}.%i.log.gz`

- Command line: `--logging.log-file-name-pattern="/var/log/coral/archive/%d{yyyy/MM, aux}/%d{yyyy-MM-dd}.%i.log.gz"`
- Config file: `logging.log_file_name_pattern = "/var/log/coral/archive/%d{yyyy/MM, aux}/%d{yyyy-MM-dd}.%i.log.gz"`

The pattern for archived log files. Read more [here](https://logback.qos.ch/manual/appenders.html#tbrpFileNamePattern).

# Max history
**default** `12`

- Command line: `--logging.max-history=20`
- Config file: `logging.max_history = 20`

The maximum number of archived log files to keep. Read more [here](https://logback.qos.ch/manual/appenders.html#tbrpMaxHistory).

# Log total size cap
**default** `3GB`

- Command line: `--logging.log-total-size-cap="1GB"`
- Config file: `logging.log_total_size_cap = "1GB"`

The maximum total size of all archived log files. Read more [here](https://logback.qos.ch/manual/appenders.html#tbrpTotalSizeCap).

# Clear log files on server start
**default** `false`

- Command line: `--logging.log-clear-history-on-start=true`
- Config file: `logging.log_clear_history_on_start = true`

If this is true, archived log files that are configured to be deleted will be deleted when the server starts. Read more [here](https://logback.qos.ch/manual/appenders.html#tbrpCleanHistoryOnStart).

# Max file size
**default** `10MB`

- Command line: `--logging.max-file-size="5MB"`
- Config file: `logging.max_file_size = "5MB"`

The maximum size of the current log file; when the current log file hits this size, the log file will be archived. Read more [here](https://logback.qos.ch/manual/appenders.html#maxFileSize).
