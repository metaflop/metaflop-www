SimpleNavigation::Configuration.run do |navigation|  
    navigation.items do |primary|
        primary.item :news, 'News', '/', :highlights_on => /\/$/
        primary.item :projects, 'Projects', '/projects'
        primary.item :fonts, 'Fonts', '/fonts'
        primary.item :generator, 'Generator', '/generator'

        primary.dom_class = 'main'
    end
end
