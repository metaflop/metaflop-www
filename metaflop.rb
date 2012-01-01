class Metaflop

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
        :contrast
    ]

    # the mapping between the defined params in the mf file and this class' properties
    MF_MAPPINGS = {
        'u#' => :unit_width,
        'cap#' => :cap_height,
        'mean#' => :mean_height,
        'bar' => :bar_height,
        'asc#' => :ascender_height,
        'desc#' => :descender_height,
        'o#' => :overshoot,
        'incx' => :horizontal_increase,
        'incy' => :vertical_increase,
        'appert' => :apperture,
        'superness' => :superness,
        'px#' => :pen_size,
        'py#' => :pen_size,
        'corner#' => :corner,
        'cont' => :contrast
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
            FileUtils.cp_r(Dir['mf/*'], "#{@out_dir}")
        end

        @char_number ||= 1
    end

    # returns an gif image for a single character preview
    def preview_single
        generate(
            generate: 'gftodvi adj.2602gf',
            convert_svg: "-density 60",
            convert_gif: "-chop 0x15 -extent 'x315'",
            char_number: char_number
        )
    end

    def preview_chart
        cleanup_tmp_dir
        generate(
            generate: %Q{latex -output-format=dvi -jobname=adj "\\\\documentclass[a4paper]{report} \\begin{document} \\pagestyle{empty} \\font\\big=adj at 22pt \\noindent \\big \\begin{center} \\setlength{\\tabcolsep}{18pt} \\begin{tabular}{ c  c  c  c  c  c  c }  A & B & C & D & E & F & G \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr H & I & J & K & L & M & N \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr  O & P & Q & R & S & T & U  \\\\  \\cr  &   &   &   &   &   &   \\\\ \\cr  &   &   &   &   &   &   \\\\ \\cr  V & W & X & Y & Z   \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr a & b & c & d & e & f & g \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr h & i & j & k & l & m & n \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr o & p & q & r & s & t & u \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr v & w & x & y & z & . & ! \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr   &   &   &   &   &   &   \\\\ \\cr \\end{tabular}  \\end{center} \\end{document}"},
            convert_custom: "dvigif -D 200 adj.dvi -o adj.gif >> /dev/null && convert adj.gif -trim +repage -resize 'x315'"
        )
    end

    def preview_typewriter
        cleanup_tmp_dir
        generate(
            generate: %Q{latex -output-format=dvi -jobname=adj "\\\\documentclass[a4paper]{report} \\begin{document} \\pagestyle{empty} \\font\\big=adj at 20pt \\noindent \\big \\begin{flushleft}#{@text} \\end{flushleft} \\end{document}"},
            convert_custom: "dvigif -D 200 adj.dvi -o adj.gif >> /dev/null && convert adj.gif -trim +repage -resize '675'"
        )
    end

    def font_otf
        cleanup_tmp_dir
        `cd #{@out_dir} && perl mf2pt1.pl adj.mf`
        File.read("#{@out_dir}/adj.otf")
    end

    # returns the metafont parameter instructions (aka adj.mf) as an array (each param)
    def mf_args
        unless @mf_args
            @mf_args = File.readlines("mf/adj.mf")
                .delete_if do |x|            # remove comment and empty lines
                    stripped = x.strip
                    stripped == '' || stripped[0] == '%'
                end
                .map do |x|                  # remove comments at the end of the line
                    pair = x[/([^%]+)/, 0].strip
                    splits = pair.split(':=')
                    if (splits.length == 2)
                        # replace the default value from the file if we have a value set for the parameter
                        mapping = MF_MAPPINGS[splits[0]]
                        value = mapping ? send(mapping) : nil
                        if (value && !value.empty?)
                            pair = splits[0] + ':=' + splits[1].gsub(/[\d\/\.]+/, value)
                        end
                    end
                    pair
                end
        end

        @mf_args
    end

    def mf_args_values
        values = {}
        mf_args.each do |x|
            splits = x.delete('#').split(':=')
            values[splits[0].to_sym] = splits[1].to_f
        end
        values
    end

    # generates the image for the specified tool chain
    #
    # @param options [Hash] optional parameters
    # @option options [String] :generate tool chain that gets executed in the tmp output dir
    # @option options [String] :convert_svg parameters for the 'convert' task for the svg image
    # @option options [String] :convert_gif parameters for the 'convert' task for the gif image
    # @option options [String] :convert_custom the custom convert call, use this instead of :convert_svg / :convert_gif
    # @option options [String] :char_number the nth character
    def generate(options)
        char_number = options[:char_number]

        if char_number
            char_number = char_number.to_s.rjust(2, '0')
            svg_name = "adj-#{char_number}.svg"
        else
            char_number = "01"
            svg_name = "adj.svg"
        end

        convert = options[:convert_custom] || "convert #{options[:convert_svg]} #{svg_name} #{options[:convert_gif]}"

        success = system(
                    %Q{cd mf > /dev/null &&
                    mf -halt-on-error -jobname=adj -output-directory=#{@out_dir} \\\\"#{mf_args.join}" > /dev/null}
                  )

        # don't bother if metafont failed
        if success
            command = %Q{cd #{@out_dir} &&
                         echo "#{mf_args.join}" > adj.mf &&
                         #{options[:generate]} > /dev/null &&
                         dvisvgm -TS0.75 -M16 -n -p #{char_number} adj.dvi > /dev/null &&
                         #{convert} gif:-}

            puts command
            # hide all output but the last one, which returns the image
            `#{command}`
        else
            nil
        end
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
