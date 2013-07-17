SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.item :twitter, '<i class="icon-twitter"></i>',
      'http://twitter.com/metaflop', :link => { :target => '_blank' }
    primary.item :facebook, '<i class="icon-facebook"></i>',
      'http://www.facebook.com/metaflop', :link => { :target => '_blank' }
    primary.item :github, '<i class="icon-github"></i>',
      'https://github.com/greyfont', :link => { :target => '_blank' }
    primary.item :terms, 'Terms', '/terms'
    primary.item :faq, 'FAQ', '/faq'

    primary.dom_class = 'meta'
  end
end
