#ActiveRecord::QueryMethods

module ActiveRecord

  class Relation

    SET_DEFAULT_VALUES = lambda do |object|
      field_types = object.class.field_types
      attrs = object.attributes.to_options

      attrs.keys.each do |attr|
        if field_types[attr] && field_types[attr].is_a?(Array) && field_types[attr].size == 2
          attrs[attr] = field_types[attr].last
        end
      end

      object.attrs = attrs
      object

    end

    def first
      object = super
      SET_DEFAULT_VALUES.call(object) if object.class.field_types && object.class.columns.empty?
    end
#
    def last
      object = super
      SET_DEFAULT_VALUES.call(object) if object.class.field_types && object.class.columns.empty?
    end
#
    def all
      objects = super

      if objects.any? && objects.first.class.field_types && objects.first.class.columns.empty?
        objects.each_with_index do |obj, index|
          objects[index] = SET_DEFAULT_VALUES.call(obj) # Some redundancy here, please refactor
          # ( no need to check field_types for all objects of the same class )
        end
      end
    end

  end

end