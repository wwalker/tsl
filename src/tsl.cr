# TODO: Write documentation for `Tsl`
require "option_parser"
require "pretty_print"

class Tsl
  VERSION = "0.1.0"

  class Config
    property name : String,
      path : String,
      time_stamp : Bool,
      start_time : Bool,
      end_time : Bool

    def initialize(@name, @path, @time_stamp)
      @name = PROGRAM_NAME.gsub(/^.*\//, "")
      @path = ENV["HOME"] + "/logs"
      @time_stamp = false
      @start_time = false
      @end_time = false
    end
  end

  def initialize
    # default_config
    @config = Config.new
  end

  def parse_args
    OptionParser.parse do |parser|
      parser.banner = "tsl - Time Stamped Logfiles
tsl [ (-n|--name) LOGFILEBASE | (-p|--path) LOGFILEBASEPATH] COMMAND [args ...]
tsl will create a time stamped logfile and execute the program and args
  passed to it.  It will also symlink BASENAME to the new logfile
E.g.:
  tsl shred /usr/bin/my-bash
  tsl -n nuked shred /usr/bin/my-bash
  tsl -p ~/tmp -n Shred shred /usr/bin/my-bash
  tsl --path ~/tmp -n Shred shred /usr/bin/my-bash
      "

      parser.on "-n LOGFILE_BASENAME", "--name=LOGFILE_BASENAME", "Logfile basename (defaults to $0)" { |name| @config.name = name }
      parser.on "-p LOG_DIR", "--path=LOG_DIR", "Log directory (defaults to ~/logs)" { |path| @config.path = path }
      parser.on "-t", "--time-stamp", "Time stamp each line of stdin" { @config.time_stamp = true }
      parser.on "-S", "--start-time", "Upon start, print 'Execution begins' to the log file" { @config.start_time = true }
      parser.on "-E", "--end-time", "Upon EOF, print 'Execution ends' to the log file" { @config.end_time = true }
      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        STDERR.puts parser
        exit(1)
      end

      parser.on "-v", "--version", "Show version" do
        puts Tsl::VERSION
        exit
      end
      parser.on "-h", "--help", "Show help" do
        puts parser
        exit
      end
    end
  end

  def output_line(text : String)
    puts text
  end

  def run
    parse_args
    pp @config

    output_line("Execution begins") if @config.start_time

    output_line("Execution ends") if @config.end_time
  end
end

Tsl.new.run
