SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.item :modulator, 'Modulator', '/modulator', :highlights_on => /^\/modulator/
    primary.item :fonts, 'Metafonts', '/metafonts', :highlights_on => /^\/metafonts/

    primary.dom_class = 'main'
  end
end
