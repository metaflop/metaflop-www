SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.item :twitter, '<i class="icon-twitter"></i>',
      'http://twitter.com/metaflop', link_html: {
        target: '_blank', class: 'tooltip', title: 'follow us on twitter'
      }
    primary.item :facebook, '<i class="icon-facebook"></i>',
      'http://www.facebook.com/metaflop', link_html: {
        target: '_blank', class: 'tooltip', title: 'like us on facebook'
      }
    primary.item :github, '<i class="icon-github"></i>',
      'https://github.com/metaflop', link_html: {
        target: '_blank', class: 'tooltip', title: 'get the source code on github'
      }
    primary.item :terms, 'Terms', '/terms'
    primary.item :faq, 'FAQ', '/faq'

    primary.dom_class = 'meta'
  end
end
