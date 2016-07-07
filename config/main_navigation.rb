SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :modulator, 'Modulator', '/modulator', highlights_on: /^\/modulator/
    primary.item :fonts, 'Metafonts', '/metafonts/adjuster', highlights_on: /^\/metafonts/
    primary.item :showcases, 'Showcases', '/showcases/off_grid', highlights_on: /^\/showcases/

    primary.dom_class = 'main'
  end
end
