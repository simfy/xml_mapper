# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{xml_mapper}
  s.version = "0.5.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tobias Schwab"]
  s.date = %q{2011-08-02}
  s.description = %q{Declarative XML to Ruby mapping}
  s.email = %q{tobias.schwab@dynport.de}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "autotest/discover.rb",
    "features/step_definitions/xml_mapper_steps.rb",
    "features/support/env.rb",
    "features/xml_mapper.feature",
    "lib/xml_mapper.rb",
    "lib/xml_mapper_hash.rb",
    "spec/example_spec.rb",
    "spec/fixtures/base.xml",
    "spec/my_mapper.rb",
    "spec/spec_helper.rb",
    "spec/xml_mapper_hash_spec.rb",
    "spec/xml_mapper_spec.rb",
    "xml_mapper.gemspec"
  ]
  s.homepage = %q{http://github.com/dynport/xml_mapper}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Declarative XML to Ruby mapping}
  s.test_files = [
    "spec/example_spec.rb",
    "spec/my_mapper.rb",
    "spec/spec_helper.rb",
    "spec/xml_mapper_hash_spec.rb",
    "spec/xml_mapper_spec.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_development_dependency(%q<autotest>, [">= 0"])
      s.add_development_dependency(%q<autotest-growl>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.1.0"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<autotest>, [">= 0"])
      s.add_dependency(%q<autotest-growl>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.1.0"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<autotest>, [">= 0"])
    s.add_dependency(%q<autotest-growl>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.1.0"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

