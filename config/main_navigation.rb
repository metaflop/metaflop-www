SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.item :news, 'News', '/', :highlights_on => /\/$/
    primary.item :fonts, 'Fonts', '/fonts'
    primary.item :modulator, 'Modulator', '/modulator'

    primary.dom_class = 'main'
  end
end
