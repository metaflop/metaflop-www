Sequel.migration do
  up do
    Url.each do |url|

      if url.params['apperture']
        url.params['aperture'] = url.params.delete('apperture')
        url.save
      end
    end
  end

  down {}
end
