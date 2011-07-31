module ApplicationHelper
  def show_flash
    fl = ''
    f_names = flash.keys.map { |key| (key.to_s.gsub /\s+/, "_").to_sym }
    for name in f_names
      if flash[name]
        fl = fl + "<div class=\"flash_entry flash_#{name}\">#{flash[name]}</div>"
      end
      flash[name] = nil;
    end
    fl = '<div class="flash">'+fl+'</div>' unless fl.empty?

    return fl.html_safe
  end
end
