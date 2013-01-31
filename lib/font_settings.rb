#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require 'fileutils'

class FontSettings

  VALID_OPTIONS_KEYS = [
    :out_dir,
    :char,
    :text,
    :font_hash,
    :fontface
  ]

  attr_accessor *VALID_OPTIONS_KEYS

  def initialize(args = {})
    VALID_OPTIONS_KEYS.each do |key|
      instance_variable_set("@#{key}".to_sym, args[key])
    end

    # defaults
    @fontface ||= 'Bespoke'
    @out_dir ||= '/tmp/metaflop/'
    # one tmp dir per fontface
    @out_dir = File.join(@out_dir, @fontface.downcase)
    @char ||= 'A'

    setup_tmp_dir
  end

  def font_name
    "#{@fontface}-#{@font_hash}"
  end

  def year
    Time.new.year
  end

  def setup_tmp_dir
    if @out_dir && !File.directory?(@out_dir)
      FileUtils.mkdir_p(@out_dir)
      # copy everything we need to generate the fonts to the tmp dir
      FileUtils.cp_r(Dir["{mf/metaflop-font-#{@fontface.downcase}/*,bin/*}"], "#{@out_dir}")
    end
  end

  def cleanup_tmp_dir
    raise '@out_dir is empty!' unless @out_dir
    FileUtils.rm_f Dir["#{@out_dir}/*.{dvi,aux,tfm,pfb,afm,*pk,*gf}"]
  end

end
