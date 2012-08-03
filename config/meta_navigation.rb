SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.item :terms, 'Terms', '/terms'
    primary.item :faq, 'FAQ', '/faq'

    primary.dom_class = 'meta'
  end
end
