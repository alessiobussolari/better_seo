# frozen_string_literal: true

require_relative "lib/better_seo/version"

Gem::Specification.new do |spec|
  spec.name = "better_seo"
  spec.version = BetterSeo::VERSION
  spec.authors = ["alessiobussolari"]
  spec.email = ["alessio@cosmic.tech"]

  spec.summary = "Comprehensive SEO gem for Ruby and Rails applications"
  spec.description = "BetterSeo provides a clean, fluent DSL for managing meta tags, Open Graph, Twitter Cards, XML sitemaps, and more. Features include automatic HTML generation, dynamic sitemap generation, validation, Rails integration, and 99.7% test coverage."
  spec.homepage = "https://github.com/alessiobussolari/better_seo"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alessiobussolari/better_seo"
  spec.metadata["changelog_uri"] = "https://github.com/alessiobussolari/better_seo/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.end_with?(".gem") ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "activesupport", ">= 6.1"
  spec.add_dependency "mini_magick", "~> 4.11"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.22"
end
