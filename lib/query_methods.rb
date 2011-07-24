#ActiveRecord::QueryMethods

module ActiveRecord

  class Relation

    def first
      object = super
      set_default_values(object) if object.class.field_types && object.class.columns.empty?
    end
#
    def last
      object = super
      set_default_values(object) if object.class.field_types && object.class.columns.empty?
    end
#
    def all
      objects = super

      if objects.any? && objects.first.class.field_types && objects.first.class.columns.empty?
        objects.each_with_index do |obj, index|
          objects[index] = set_default_values(obj) # Some redundancy here, please refactor
          # ( no need to check field_types for all objects of the same class )
        end
      end
    end

    private

    def set_default_values(object)
      defaults = object.class.defaults
      attrs = object.attributes.to_options

      attrs.keys.each { |attr|
        attrs[attr] = defaults[attr] if attrs[attr].nil?
      }

      object.attrs = attrs
      object
    end

  end

end