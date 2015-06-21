SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.item :twitter, '<i class="fa fa-twitter"></i>',
      'http://twitter.com/metaflop', link_html: {
        target: '_blank', class: 'tooltip', title: 'visit us on twitter'
      }
    primary.item :facebook, '<i class="fa fa-facebook"></i>',
      'http://www.facebook.com/metaflop', link_html: {
        target: '_blank', class: 'tooltip', title: 'visit us on facebook'
      }
    primary.item :github, '<i class="fa fa-github"></i>',
      'https://github.com/metaflop', link_html: {
        target: '_blank', class: 'tooltip', title: 'visit us on github'
      }
    primary.item :'donate-paypal', '<i class="fa fa-dollar"></i>',
      '#', link_html: {
        class: 'tooltip', title: 'donate by paypal'
      }
    primary.item :about, 'About', '/about'
    primary.item :faq, 'FAQ', '/faq'

    primary.dom_class = 'meta'
  end
end
