require "msgknife/version"
require 'msgpack'
require 'optparse'

module Msgknife
  class Stream
    attr_accessor :optpsr

    def initialize
      @out_encode = false
      @optpsr = OptionParser.new
      @optpsr.on('-m', 'output as msgpack encode') { |v| @out_encode = v }
      @optpsr.on('-F', 'input as fluentd format')  { |v| @in_fluentd = v }
      @argv = []
    end

    def run(cmd_argv, range = nil)
      args = @optpsr.parse(cmd_argv)

      unless range.nil?
        raise "Not enough arguments" if args.size < range.last + 1
        @argv = args.slice!(range)
      end

      setup(@argv)
      read_stream(args)
      teardown
    end


    def read_io(io)
      u = MessagePack::Unpacker.new(io)
      begin
        u.each {|obj|
          if @in_fluentd
            recv(obj[2], obj[1], obj[0])
          else
            recv(obj, nil, nil)
          end
        }
      rescue EOFError
        # ignore
      rescue Interrupt
        return
      end
    end

    def read_stream(files=nil)
      if files == nil or files.size == 0
        read_io(STDIN)
      else
        f_list = Array.new
        if files.instance_of? String
          f_list << files
        else
          f_list += files
        end

        f_list.each do |fpath|
          if File.directory?(fpath)
            Find.find(fpath) do |file|
              next if File.directory?(file)
              read_io(File.open(file, 'r'))
            end
          else
            read_io(File.open(fpath, 'r'))
          end 
        end
      end
    end

    def write_stream(obj, ts=nil, tag=nil)
      if @out_encode == false
        if ts.nil? and tag.nil?
          pp obj
        else
          pp [tag, ts, obj]
        end
      else
        if ts.nil? and tag.nil?
          STDOUT.write(obj.to_msgpack)
        else
          STDOUT.write([tag, ts, obj].to_msgpack)
        end
      end
      rescue Errno::EPIPE => e ;      
    end


    def setup(argv)
      raise 'setup(argv) must be implemented' if argv.size > 0
    end

    def recv(obj, ts, tag)
      raise 'exec(obj) must be implemented'
    end

    def teardown; end
  end

end
