require 'time'
require 'term/ansicolor'

module Betterlog
  class Log
    # Formats log events for structured logging output.
    #
    # This class provides functionality to format log events into various
    # output formats, including JSON representation and pretty-printed strings
    # with color support. It handles the conversion of log data into
    # human-readable formats while maintaining structured logging capabilities.
    #
    # @see Betterlog::Log::Event
    # @see Betterlog::Log::EventFormatter#format
    class EventFormatter
      include Term::ANSIColor
      include ComplexConfig::Provider::Shortcuts

      # Initializes a new EventFormatter instance with the given log event.
      #
      # This constructor sets up the formatter with a specific log event to be
      # formatted, preparing it for subsequent formatting operations such as
      # JSON generation or pretty printing with color support.
      #
      # @param event [Betterlog::Log::Event] the log event to be formatted by
      # this instance
      # @return [Betterlog::Log::EventFormatter] a new EventFormatter instance
      def initialize(event)
        @event = event
      end

      # Formats the log event according to specified options.
      #
      # This method processes a log event and returns either a JSON
      # representation or a formatted string based on the provided formatting
      # options. It supports pretty printing with custom format patterns and
      # optional colorization.
      #
      # @param pretty [ Boolean, Symbol ] when true, enables pretty printing;
      #   when :format, uses a specific format pattern; otherwise uses JSON generation
      # @param color [ Boolean ] whether to apply color formatting to the output
      # @param format [ Symbol ] the format identifier to use for pretty printing
      #
      # @return [ String ] the formatted log event as a string
      #
      # @see Betterlog::Log::EventFormatter#format_pattern
      # @see JSON.generate
      def format(pretty: false, color: false, format: :default)
        old_coloring, Term::ANSIColor.coloring = Term::ANSIColor.coloring?, color
        f = cc.log.formats[format] and format = f
        case pretty
        when :format
          format_pattern(format: format)
        else
          JSON.generate(@event)
        end
      ensure
        Term::ANSIColor.coloring = old_coloring
      end

      private

      # Colorizes a string value based on configured styles for a given key and
      # optional value.
      #
      # This method applies visual styling to a string by looking up the
      # appropriate style configuration based on the provided key and value,
      # then applying that style using the internal apply_style method. The
      # colorization logic supports both static and dynamic styling based on
      # the value being formatted.
      #
      # <b>Style Configuration Patterns</b>
      #
      # Styles can be configured in several ways:
      #
      # <b>Static Styles</b>
      # - String: Single ANSI color code (e.g., "red", "bold")
      # - Array: Multiple ANSI codes (e.g., ["red", "bold"])
      #
      # <b>Dynamic Styles</b>
      # - ComplexConfig::Settings: Different styles based on value content
      #   Example: { debug: "green", error: "red" } where the style is selected based on the value
      #
      # <b>Usage Examples</b>
      #
      # Given a configuration like:
      #   styles:
      #     'timestamp': [ yellow, bold ]
      #     severity:
      #       debug: green
      #       info: green
      #       warn:  yellow
      #       error: red
      #
      # The method will:
      # - Colorize "{timestamp}" with yellow/bold styling
      # - Colorize "{severity}" with green for "debug"/"info", yellow for "warn", red for "error"
      #
      # @param key [Object] the lookup key for determining the style configuration
      # @param value [Object] the value used to determine which specific style to apply
      # @param string [Object] the string to be colorized, defaults to the key if not provided
      # @return [String] the colorized string based on the configured styles
      # @see Betterlog::Log::EventFormatter#apply_style
      #
      # @example Static styling
      #   colorize(:timestamp, nil, "2023-12-01")  # Returns colored timestamp string
      #
      # @example Dynamic styling based on value
      #   colorize(:severity, :error, "ERROR")    # Returns red-colored string
      def colorize(key, value, string = key)
        case style = cc.log.styles[key]
        when nil, String, Array
          apply_style(style, string)
        when ComplexConfig::Settings
          apply_style(style[value], string)
        end
      end

      # Applies visual styling to a string using the provided style
      # configuration.
      #
      # This method takes a style definition and applies it to a given string,
      # supporting both single styles and arrays of styles. It handles the case
      # where no style is provided by returning the string with reset
      # formatting. When multiple styles are specified, they are applied
      # sequentially to the string.
      #
      # @param style [ Object ] The style configuration to apply, which can be nil,
      #   a string, an array of styles, or a ComplexConfig::Settings object
      # @param string [ String ] The input string to which the style will be applied
      # @return [ String ] The styled string with appropriate ANSI color codes inserted
      def apply_style(style, string)
        style.nil? and return string + Term::ANSIColor.reset
        string = Term::ANSIColor.uncolor(string)
        if style.respond_to?(:each)
          style.
            each.
            map { |s| -> v { __send__(:color, s, v) } }.
            inject(string) { |v, s| s.(v) }
        else
          __send__(:color, style, string)
        end
      end

      # Formats a log event using a specified pattern with support for directives and colorization.
      #
      # This method processes a format string by replacing placeholders with actual event data,
      # applying formatting directives for special handling of values like objects or timestamps,
      # and optionally applying color styling based on configured styles.
      #
      # <b>Format Pattern Syntax</b>
      #
      # Format patterns use curly braces `{}` to define placeholders with optional directives:
      #
      # <b>Basic Key Substitution</b>
      # - `{key}` - Substitutes the value of `@event[key]`
      # - `{-key}` - Invisible variant; omits output when value is nil (instead of showing `{key}`)
      #
      # <b>Object Formatting Directives</b>
      # - `{%O%key}` - Formats complex objects (arrays/hashes) with nested structure visualization
      #   Example: Shows arrays with bullet points and hashes with key-value pairs
      #
      # <b>Timestamp Formatting Directives</b>
      # - `{%t%key}` - Formats timestamp values with various time formats based on flag:
      #   - `%ut%key` - UTC ISO8601 format (e.g., "2023-12-01T10:30:45.123Z")
      #   - `%lt%key` - Local time ISO8601 format
      #   - `%it%key` - Unix timestamp integer (e.g., "1701423425")
      #   - `%ft%key` - Unix timestamp float (e.g., "1701423425.123")
      #   - `%t%key` (default) - UTC ISO8601 format
      #
      # <b>String Formatting Directives</b>
      # - `{%.format%key}` - Applies Ruby string formatting using the `%` operator
      #   Example: `{%.2f%price}` formats a float to 2 decimal places
      #
      # <b>Colorization</b>
      # Values are automatically colorized based on configured styles in the `styles` configuration.
      # For example, timestamp values use yellow/bold styling, and severity levels use different colors
      # based on their value (debug=green, warn=yellow, error=red, etc.).
      #
      # @param format [String] the format pattern to apply to the log event
      # @return [String] the formatted string representation of the log event
      # @see Betterlog::Log::EventFormatter#format_object
      # @see Betterlog::Log::EventFormatter#colorize
      #
      # @example Basic usage with default configuration
      #   formatter.format_pattern(format: "{%lt%timestamp} {message}")
      #
      # @example Complex formatting with object display
      #   formatter.format_pattern(format: "{%O%backtrace} {message}")
      #
      # @example Conditional display of optional fields
      #   formatter.format_pattern(format: "{file}{-%O%backtrace}")
      def format_pattern(format:)
        format.
          gsub('\n', "\n").
          gsub('\t', "\t").
          gsub(/\{(-)?(%[^%]+%)?([^}]+)\}/) {
            invisible = $1.full?
            directive = $2
            key       = $3
            value     = @event[key]
            unless value.nil?
              formatted_value =
                if directive
                  case directive
                  when /\A%O%/
                    format_object(value)
                  when /\A%([ulif])?t%/
                    flag = $1
                    t = case
                        when v = value.ask_and_send(:to_str)
                          Time.parse(v)
                        when v = value.ask_and_send(:to_time)
                          v
                        else
                          Time.at(0)
                        end
                    case flag
                    when ?u then t.utc.iso8601(3)
                    when ?l then t.localtime.iso8601(3)
                    when ?i then t.to_i.to_s
                    when ?f then t.to_f.to_s
                    else         t.utc.iso8601(3)
                    end
                  else
                    begin
                      directive[0..-2] % value
                    rescue ArgumentError
                      value.to_s
                    end
                  end
                else
                  value.to_s
                end
              colorize(key, value, formatted_value)
            else
              unless invisible
                "{#{key}}"
              end
            end
          }
      end

      # Formats complex objects into a readable string representation with
      # nested structure visualization.
      #
      # This method recursively processes arrays and hashes, converting them
      # into indented string representations that show the hierarchical
      # structure of the data. It handles nested arrays and hashes by
      # increasing the indentation level for each nesting level, making it
      # easier to visualize the data structure.
      #
      # @param object [ Object ] the object to be formatted, which can be an
      # array, hash, or any other object
      # @param depth [ Integer ] the current depth level for indentation, used
      # internally during recursion
      # @param nl [ String ] the newline character or string to use for
      # separating elements
      # @return [ String ] a formatted string representation of the object,
      # with proper indentation for nested structures
      def format_object(object, depth: 0, nl: ?\n)
        case
        when a = object.ask_and_send(:to_ary)
          result = ''
          depth += 2
          for v in a
            result << "\n#{' ' * depth}- #{format_object(v, depth: depth)}"
          end
          result
        when h = object.ask_and_send(:to_hash)
          result = ''
          depth += 2
          for k, v in h
            result << "\n#{' ' * depth}#{k}: #{format_object(v, depth: depth)}"
          end
          result
        else
          object.to_s
        end
      end
    end
  end
end
