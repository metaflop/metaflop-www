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
    :font_hash,
    :fontface,
    :year
  ]

  attr_accessor *VALID_OPTIONS_KEYS

  def initialize(args = {})
    VALID_OPTIONS_KEYS.each do |key|
      instance_variable_set("@#{key}", args[key])
    end

    defaults!

    setup_tmp_dir
  end

  def font_name
    "#{@fontface}-#{@font_hash}"
  end

  def font_source_dir
    File.expand_path("mf/metaflop-font-#{@fontface.downcase}")
  end

  def setup_tmp_dir
    if @out_dir && !File.directory?(@out_dir)
      FileUtils.mkdir_p(@out_dir)
      # only copy font.mf to the output dir (it's the only file
      # that is modified per request)
      font_file = File.join(font_source_dir, 'font.mf')
      FileUtils.cp(font_file, @out_dir)
      # symlink the rest (mf2outline / fontforge don't properly handle
      # config and other referenced files outside of the pwd)
      (Dir["{#{font_source_dir}/*,bin/*}"] - [font_file]).each do |file|
        FileUtils.ln_s(File.expand_path(file), @out_dir)
      end
    end
  end

  def cleanup_tmp_dir
    raise '@out_dir is empty!' unless @out_dir
    FileUtils.rm_f Dir["#{@out_dir}/*.{dvi,aux,tfm,pfb,afm,*pk,*gf}"]
  end

  def to_hash
    VALID_OPTIONS_KEYS.map do |key|
      [key, instance_variable_get("@#{key}")]
    end.to_h
  end

  def defaults!
    @fontface ||= 'Bespoke'
    @out_dir ||= '/tmp/metaflop/'
    # one tmp dir per fontface
    @out_dir = File.join(@out_dir, @fontface.downcase)
    @year = Time.new.year
  end
end
