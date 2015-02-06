# Msgknife

Utilities of MessagePack format file and stream.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'msgknife'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install msgknife

## Usage

### mpp: Msgpack Prittey Print

	$ hexdump -C data.msg
    0000000 82 a1 61 01 a1 62 01 82 a1 61 03 a1 62 04 82 a1
    0000010 61 01 a1 62 08                                 
    0000015
    $ mpp data.msg
    {"a"=>1, "b"=>1}
    {"a"=>3, "b"=>4}
    {"a"=>1, "b"=>8}

### mkeys: Msgpack KEYS

Count and show the number of each key fields.

    $ mkeys data.msg
	{"a"=>3, "b"=>3}

### mentropy: Msgpack ENTROPY

    $ mentropy data.msg              
    {"a"=>0.9182958340544896, "b"=>1.584962500721156}


## Common Options

### `-m` output with msgpack encoding

    $ mkeys data.msg
	{"a"=>3, "b"=>3}
    $ mkeys -m data.msg | hexdump    	
    0000000 82 a1 61 03 a1 62 03                           
    0000007


## Contributing

1. Fork it ( https://github.com/[my-github-username]/msgknife/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
