#ActiveRecord::QueryMethods

module ActiveRecord

  class Base

    def attribute_names
      # AR sorts attributes alphabetically. We don't need that behivour for our
      # report models
      if self.class.respond_to?(:abstract_table?)
        @attributes.keys
      else
        @attributes.keys.sort
      end
    end

  end

  class Relation

    # This was made to set the default values for report fields ( in case field is NULL )
    # But this may be somewhat confusing, since if user will try to filter results by default value - he won't get what he wants
    # ( because NULL's are still NULLS in the database )

    def first
      object = super
      klass = object.class

      if klass.respond_to?(:abstract_table?) && klass.populates_defaults
        set_default_values(object)
      else
        object
      end
    end

    def last
      object = super
      klass = object.class

      if klass.respond_to?(:abstract_table?) && klass.populates_defaults
        set_default_values(object)
      else
        object
      end
    end


    def all
      objects = super
      klass = objects.first.class

      if objects.any? && klass.respond_to?(:abstract_table?) && klass.populates_defaults
        objects.each_with_index do |obj, index|
          objects[index] = set_default_values(obj)
        end
      else
        objects
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
