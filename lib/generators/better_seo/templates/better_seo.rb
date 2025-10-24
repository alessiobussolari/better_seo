# frozen_string_literal: true

BetterSeo.configure do |config|
  # Site-wide settings
  config.site_name = "My Site"
  config.default_locale = :en
  config.available_locales = %i[en it fr de es]

  # Meta tags configuration
  config.meta_tags.default_title = "Default Title"
  config.meta_tags.title_separator = " | "
  config.meta_tags.append_site_name = true
  config.meta_tags.default_description = "Default description for your website"
  config.meta_tags.default_keywords = %w[keyword1 keyword2 keyword3]
  config.meta_tags.default_author = "Your Name or Company"

  # Open Graph configuration
  config.open_graph.enabled = true
  config.open_graph.site_name = "My Site"
  config.open_graph.default_type = "website"
  config.open_graph.default_locale = "en_US"
  config.open_graph.default_image.url = "https://example.com/default-og-image.jpg"
  config.open_graph.default_image.width = 1200
  config.open_graph.default_image.height = 630
  config.open_graph.default_image.alt = "Default image description"

  # Twitter Cards configuration
  config.twitter.enabled = true
  config.twitter.site = "@yoursite"
  config.twitter.creator = "@yourcreator"
  config.twitter.card_type = "summary_large_image"

  # Structured Data configuration
  config.structured_data.enabled = true
  # config.structured_data.organization = {
  #   name: "My Organization",
  #   url: "https://example.com",
  #   logo: "https://example.com/logo.png"
  # }
end
