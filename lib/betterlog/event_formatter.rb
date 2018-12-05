class EventFormatter
  include Term::ANSIColor

  def initialize(event)
    @event = event
  end

  def format(pretty: false, color: false, format: :default)
    old_coloring, Term::ANSIColor.coloring = Term::ANSIColor.coloring?, color
    f = cc.log.formats[format] and format = f
    case pretty
    when :format
      format_pattern(format: format)
    else
      @event.to_json
    end
  ensure
    Term::ANSIColor.coloring = old_coloring
  end

  private

  def colorize(key, value, string = key)
    case style = cc.log.styles[key]
    when nil, String, Array
      apply_style(style, string)
    when ComplexConfig::Settings
      apply_style(style[value], string)
    end
  end

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

  def format_pattern(format:)
    format.
      gsub('\n', "\n").
      gsub('\t', "\t").
      gsub(/\{(-)?(%[^%]+%)?([^}]+)\}/) {
        invisible = $1.full?
        directive = $2
        key       = $3
        if value = @event[key]
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
