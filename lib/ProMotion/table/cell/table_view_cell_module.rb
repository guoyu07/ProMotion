module ProMotion
  module TableViewCellModule
    # @requires module:Styling
    include Styling

    attr_accessor :data_cell, :table_screen

    def setup(data_cell, screen)
      self.table_screen = WeakRef.new(screen)
      self.data_cell = data_cell

      set_styles
      set_title
      set_subtitle
      set_image
      set_remote_image
      set_accessory_view
      set_selection_style
    end

  protected

    def set_styles
      set_attributes self, data_cell[:style] if data_cell[:style]
    end

    def set_title
      set_attributed_text(self.textLabel, data_cell[:title])
    end

    def set_subtitle
      return unless data_cell[:subtitle] && self.detailTextLabel
      set_attributed_text(self.detailTextLabel, data_cell[:subtitle])
      self.detailTextLabel.backgroundColor = UIColor.clearColor
      self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
    end

    def set_remote_image
      return unless data_cell[:remote_image] && jm_image_cache?
      self.imageView.setImageWithURL(data_cell[:remote_image][:url].to_url, placeholder: remote_placeholder)
      self.imageView.layer.masksToBounds = true
      self.imageView.layer.cornerRadius = data_cell[:remote_image][:radius] if data_cell[:remote_image][:radius]
      self.imageView.contentMode = map_content_mode_symbol(data_cell[:remote_image][:content_mode]) if data_cell[:remote_image][:content_mode]
    end

    def set_image
      return unless data_cell[:image]
      cell_image = data_cell[:image].is_a?(Hash) ? data_cell[:image][:image] : data_cell[:image]
      cell_image = UIImage.imageNamed(cell_image) if cell_image.is_a?(String)
      self.imageView.layer.masksToBounds = true
      self.imageView.image = cell_image
      self.imageView.layer.cornerRadius = data_cell[:image][:radius] if data_cell[:image].is_a?(Hash) && data_cell[:image][:radius]
    end

    def set_accessory_view
      return self.accessoryView = nil unless data_cell[:accessory] && data_cell[:accessory][:view]
      if data_cell[:accessory][:view] == :switch
        self.accessoryView = switch_view
      else
        self.accessoryView = data_cell[:accessory][:view]
        self.accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth
      end
    end

    def set_selection_style
      self.selectionStyle = map_selection_style_symbol(data_cell[:selection_style]) if data_cell[:selection_style]
    end

  private

    def jm_image_cache?
      return true if self.imageView.respond_to?("setImageWithURL:placeholder:")
      PM.logger.error "ProMotion Warning: to use remote_image with TableScreen you need to include the CocoaPod 'JMImageCache'."
      false
    end

    def remote_placeholder
      UIImage.imageNamed(data_cell[:remote_image][:placeholder]) if data_cell[:remote_image][:placeholder].is_a?(String)
    end

    def switch_view
      switch = UISwitch.alloc.initWithFrame(CGRectZero)
      switch.setAccessibilityLabel(data_cell[:accessory][:accessibility_label] || data_cell[:title])
      switch.addTarget(self.table_screen, action: "accessory_toggled_switch:", forControlEvents:UIControlEventValueChanged)
      switch.on = !!data_cell[:accessory][:value]
      switch
    end

    def set_attributed_text(label, text)
      text.is_a?(NSAttributedString) ? label.attributedText = text : label.text = text
    end

    def map_content_mode_symbol(symbol)
      {
        scale_to_fill:     UIViewContentModeScaleToFill,
        scale_aspect_fit:  UIViewContentModeScaleAspectFit,
        scale_aspect_fill: UIViewContentModeScaleAspectFill,
        mode_redraw:       UIViewContentModeRedraw
      }[symbol] || symbol
    end

    def map_selection_style_symbol(symbol)
      {
        none:     UITableViewCellSelectionStyleNone,
        blue:     UITableViewCellSelectionStyleBlue,
        gray:     UITableViewCellSelectionStyleGray,
        default:  UITableViewCellSelectionStyleDefault
      }[symbol] || symbol
    end
  end
end
