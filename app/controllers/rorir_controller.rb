class RorirController < ActionController::Base
  caches_page :show_with_style
  
  def show_with_style
    options.merge!(defaults_from_style(params[:style]))
    
    respond_to do |format|
      format.png do
        send_data canvas.to_blob, :disposition => 'inline', :type => 'image/png'
      end
    end
  end
  
  def show_without_style
    options.merge!(rorir_options_from_params) unless rorir_options_from_params.blank?
    
    respond_to do |format|
      format.png do
        send_data canvas.to_blob, :disposition => 'inline', :type => 'image/png'
      end
    end
  end
  
  private
    def options
      @options ||= {
        :font              => 'Vera.ttf',
        :size              => 40,
        :colour            => '#FFFFFF',
        :background_colour => 'none',
        :gravity           => Magick::CenterGravity
      }
    end
    
    def canvas
      text           = Magick::Draw.new
      text.font      = font_path(options[:font])
      text.pointsize = options[:size]
      text.fill      = options[:colour]
      text.gravity   = options[:gravity]
      
      background_colour = options[:background_colour]
      
      canvas = Magick::Image.new(*(
        [:width, :height].map { |element| text.get_type_metrics(display_text).send(element) + padding }
      )) { self.background_color = background_colour }
      
      canvas.format           = 'PNG'
      
      text.annotate(canvas, 0, 0, 0, 0, display_text)
      
      canvas
    end
    
    def padding
      4 #px
    end
    
    def display_text
      params[:text].to_s
    end
    
    def rorir_options_from_params
      @rorir_options_from_params ||= {
        :font              =>     params[:font],
        :size              =>     params[:size].blank? ? nil :     params[:size].to_i,
        :colour            =>   params[:colour].blank? ? nil : "##{params[:colour]}",
        :background_colour => params[:bgcolour].blank? ? nil : "##{params[:bgcolour]}"
      }.reject { |key, value| value.blank? }
    end
    
    def defaults_from_style(style)
      style  = style.to_sym
      styles = Rails.cache.fetch('rorir_styles') do
        file = File.join(RAILS_ROOT, 'config', 'rorir_styles.yml')
        if File.exists?(file)
          styles_hash = YAML.load_file(file).symbolize_keys
          styles_hash.each { |type, options| options.symbolize_keys! }
          styles_hash
        else
          {}
        end
      end
      raise ActiveRecord::RecordNotFound if styles[style].nil?
      styles[style]
    end
  
    def font_path(font_name)
      [
        File.join(*[RAILS_ROOT, 'fonts', font_name]),
        File.expand_path(File.join(*[File.dirname(__FILE__), '..', '..', 'fonts', font_name]))
      ].each { |path| return path if File.exists?(path) }
    
      font_name
    end
end
