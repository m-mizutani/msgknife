# -*- coding: utf-8 -*-

require "msgknife/version"
require 'msgpack'
require 'optparse'
require 'time'
require 'pp'
require 'json'

module Msgknife
  class Stream
    attr_accessor :optpsr

    def initialize
      @out_encode = false
      @optpsr = OptionParser.new
      @optpsr.on('-F', 'input as fluentd format')  { |v| @in_fluentd = v }
      @optpsr.on('-T VAL', 'key of timestamp in message')  { |v| @ts_key = v }
      @optpsr.on('-N', 'ignore if value is nil') {|v| @ignore_nil = v }
      @argv = []
      
      @output_fmt = 'console'
      @optpsr.on('-j', 'output as json') { |v| @output_fmt = 'json' }
      @optpsr.on('-m', 'output as msgpack') { |v| @output_fmt = 'msgpack' }
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
            if @ts_key.nil? or !(obj.key?(@ts_key))
              recv(obj, nil, nil)
            else
              ts = nil
              ts_val = obj[@ts_key]
              case ts_val
              when String
                dt = Time.parse(ts_val) rescue nil
                ts = dt.to_i
              when Fixnum
                ts = ts_val
              when Float
                ts = ts_val.to_i
              end
                  
              recv(obj, ts, nil)
            end
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

    def write_stream(obj, ts=nil, tag=nil, io=STDOUT)
      msg =(ts.nil? and tag.nil?) ? obj : [tag, ts, obj]

      begin
        case @output_fmt
        when 'console'; PP.pp(msg, io);
        when 'json';    JSON.dump(msg, io);
        when 'msgpack'; io.write(msg.to_msgpack);
        end
      rescue Errno::EPIPE => e ;
      end
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
