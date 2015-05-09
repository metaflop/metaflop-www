SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.item :twitter, '<i class="fa fa-twitter"></i>',
      'http://twitter.com/metaflop', link_html: {
        target: '_blank', class: 'tooltip', title: 'follow us on twitter'
      }
    primary.item :facebook, '<i class="fa fa-facebook"></i>',
      'http://www.facebook.com/metaflop', link_html: {
        target: '_blank', class: 'tooltip', title: 'like us on facebook'
      }
    primary.item :github, '<i class="fa fa-github"></i>',
      'https://github.com/metaflop', link_html: {
        target: '_blank', class: 'tooltip', title: 'get the source code on github'
      }
    primary.item :terms, 'Terms', '/terms'
    primary.item :faq, 'FAQ', '/faq'

    primary.dom_class = 'meta'
  end
end
