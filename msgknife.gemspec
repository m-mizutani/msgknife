# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'msgknife/version'

Gem::Specification.new do |spec|
  spec.name          = "msgknife"
  spec.version       = Msgknife::VERSION
  spec.authors       = ["Masayoshi Mizutani"]
  spec.email         = ["mizutani@sfc.wide.ad.jp"]
  spec.summary       = %q{MsgKnife: Utilities of MessagePack format file and stream}
  spec.description   = %q{MsgKnife makes easy to view, check and analyze MessagePack format file and stream such as Fluentd data}
  spec.homepage      = "https://github.com/m-mizutani/msgknife"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "msgpack", '~> 0.5'
  spec.add_dependency "ruby-terminfo"
  spec.add_dependency "mongo"  
end
