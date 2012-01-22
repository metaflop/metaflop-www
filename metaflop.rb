# encoding: UTF-8

#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './racklogger'
require './racksettings'
require 'mustache'

class Metaflop

    include RackLogger
    include RackSettings

    # these options can be set when instantiating this class
    VALID_OPTIONS_KEYS = [
        :out_dir,
        :char_number,
        :text,

        :unit_width,
        :cap_height,
        :mean_height,
        :bar_height,
        :ascender_height,
        :descender_height,
        :overshoot,
        :horizontal_increase,
        :vertical_increase,
        :apperture,
        :superness,
        :pen_size,
        :corner,
        :contrast,
        :sidebearing
    ]

    # the mapping between the defined params in the mf file and this class' properties
    MF_MAPPINGS = {
        'u#' => :unit_width,
        'cap#' => :cap_height,
        'mean#' => :mean_height,
        'bar' => :bar_height,
        'asc#' => :ascender_height,
        'des#' => :descender_height,
        'o#' => :overshoot,
        'incx' => :horizontal_increase,
        'incy' => :vertical_increase,
        'appert' => :apperture,
        'superness' => :superness,
        'px#' => :pen_size,
        'py#' => :pen_size,
        'corner#' => :corner,
        'cont' => :contrast,
        'sidebearing' => :sidebearing
    }

    attr_accessor *VALID_OPTIONS_KEYS

    # initialize with optional options defined in VALID_OPTIONS_KEYS
    def initialize(args = {})
        args = options.merge(args)
        VALID_OPTIONS_KEYS.each do |key|
            instance_variable_set("@#{key}".to_sym, args[key])
        end

        # defaults
        if @out_dir && !File.directory?(@out_dir)
            Dir.mkdir(@out_dir)
            FileUtils.cp_r(Dir["{mf/*,bin/*}"], "#{@out_dir}")
        end

        @char_number ||= 1
    end

    # returns an gif image for a single character preview
    def preview_single
        generate(
            generate: "#{settings[:preview_single]['generate']}",
            convert_svg: "#{settings[:preview_single]['convert_svg']}",
            convert_gif: "#{settings[:preview_single]['convert_gif']}",
            char_number: char_number
        )
    end

    def preview_chart
        cleanup_tmp_dir
        generate(
            generate: "#{settings[:preview_chart]['generate']}",
            convert_custom: "#{settings[:preview_chart]['convert_custom']}"
        )
    end

    def preview_typewriter
        cleanup_tmp_dir
        generate(
            generate: Mustache.render("#{settings[:preview_typewriter]['generate']}", :text => @text),
            convert_custom: "#{settings[:preview_typewriter]['convert_custom']}"
        )
    end

    def font_otf
        cleanup_tmp_dir

        # regenerate from the latest parameters with the sidebearings turned off
        @sidebearing = '0'
        mf_args(:force => true, :file => "#{@out_dir}/font.mf")
        generate_mf

        `cd #{@out_dir} && #{settings[:font_otf]}`

        @sidebearing = nil

        File.read("#{@out_dir}/font.otf")
    end

    # returns the metafont parameter instructions (aka font.mf) as an array (each param)
    #
    # @param options [Hash] optional parameters
    # @option options [String] :force always regenerates the mf
    # @option options [String] :file defaults to "mf/font.mf" (containing the default parameters)
    def mf_args(options = {})
        if !@mf_args || options[:force]
            options[:file] ||= "mf/font.mf"
            @mf_args = { :values => {}, :instruction => '', :ranges => {} }

            lines = File.readlines(options[:file])
            # in case the file is a one-liner already, split each statement onto a line
            lines = lines[0].split(';').map{ |x| "#{x};" } if lines.length == 1

            lines.delete_if do |x|            # remove comment and empty lines
                    stripped = x.strip
                    stripped == '' || stripped[0] == '%'
                end
                .each do |x|                  # remove comments at the end of the line
                    pair = x[/([^%]+)/, 0].strip
                    splits = pair.split(':=')

                    if (splits.length == 2)
                        key = splits[0].delete('#').to_sym
                        # store as key/value pairs
                        @mf_args[:values][key] = { :raw => splits[1], :clean => splits[1].to_f }

                        # replace the default value from the file if we have a value set for the parameter
                        mapping = MF_MAPPINGS[splits[0]]
                        value = mapping ? send(mapping) : nil
                        if (value && !value.empty?)
                            pair = splits[0] + ':=' + splits[1].gsub(/[\d\/\.]+/, value)
                        end

                        # get the ranges
                        range = x.gsub(/\s+/, '').scan(/\$([\d\.]+)\w*\/([\d\.]+)\w*$/).flatten!
                        range = [0, 1] if range.nil?
                        @mf_args[:ranges][key] = { :from => range[0], :to => range[1] }
                    end
                    # the instruction oneliner for the mf command
                    @mf_args[:instruction] = @mf_args[:instruction] + pair
                end
        end

        @mf_args
    end

    # generates the image for the specified tool chain
    #
    # @param options [Hash] optional parameters
    # @option options [String] :generate tool chain that gets executed in the tmp output dir
    # @option options [String] :convert_svg parameters for the 'convert' task for the svg image
    # @option options [String] :convert_gif parameters for the 'convert' task for the gif image
    # @option options [String] :convert_custom the custom convert call, use this instead of :convert_svg / :convert_gif
    # @option options [String] :char_number the nth character
    def generate(options = {})
        char_number = options[:char_number]

        if char_number
            char_number = char_number.to_s.rjust(2, '0')
            svg_name = "font-#{char_number}.svg"
        else
            char_number = "01"
            svg_name = "font.svg"
        end

        convert = options[:convert_custom] || "convert #{options[:convert_svg]} #{svg_name} #{options[:convert_gif]}"

        # don't bother if metafont failed
        if generate_mf
            command = %Q{cd #{@out_dir} &&
                         #{options[:generate]} > /dev/null &&
                         dvisvgm -TS0.75 -M16 -n -p #{char_number} font.dvi > /dev/null &&
                         #{convert} gif:-}

            logger.info command
            # hide all output but the last one, which returns the image
            `#{command}`
        else
            logger.error "mf generation failed for '#{mf_args}'"
            nil
        end
    end

    # returns true if the mf was successfully generated
    def generate_mf
        system(
            %Q{cd #{@out_dir} &&
            echo "#{mf_args[:instruction]}" > font.mf &&
            mf -halt-on-error -jobname=font \\\\"#{mf_args[:instruction]}" > /dev/null}
        )
    end

    def cleanup_tmp_dir
        raise '@out_dir is empty!' unless @out_dir
        FileUtils.rm_f Dir["#{@out_dir}/*.{dvi,aux,tfm,pfb,afm,*pk,*gf}"]
    end

    def options
        options = {}
        VALID_OPTIONS_KEYS.each{ |k| options[k] = send(k) }
        options
    end
end
