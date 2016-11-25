# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wbck/version'

Gem::Specification.new do |spec|
  spec.name          = "wbck"
  spec.version       = Wbck::VERSION
  spec.authors       = ["Richard Downer"]
  spec.email         = ["richard@apache.org"]

  spec.summary       = %q{The Workbench Construction Kit is a tool for creating an Amiga operating system image with lots of useful software.}
  spec.description   = %q{The Workbench Construction Kit is a tool for creating an Amiga operating system image with lots of useful software, but which leaves it up to you to decide what you want to install. It's opinionated at the micro level (for example, if you install a TCP/IP stack you will automatically get drivers for common NICs) but not at the macro level (it's up to you to decide if you want to install a TCP/IP stack or not). This means that you can get your Amiga configured with the software you prefer without having to answer hundreds of questions of minutia.}
  spec.homepage      = "https://github.com/rdowner/workbench-construction-kit"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"

  spec.add_dependency "thor"
  spec.add_dependency "paint"
end
