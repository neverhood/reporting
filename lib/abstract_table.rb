module AbstractTable


  module ClassMethods

    def columns # Dear Rails, please don't complain
      @columns ||= []
    end

    def column(name, sql_type = nil, default = nil, null = true) # Dear Rails, please don't complain
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
    end

    def view
      self::VIEW
    end

    def field_types
      opts = self.set_field_types_and_defaults
      @field_types ||= Hash[
        opts.map {|array| [array.first,
                           (array.last.is_a?(Array))? array.last.first : array.last ]
        }
      ]
    end

    def fields
      field_types.keys
    end

    def defaults
      opts = self.set_field_types_and_defaults
      @defaults ||= Hash[
        opts.map {|array| [array.first,
                  (array.last.is_a?(Array))? array.last.last : nil ]
        }
      ]
    end

  end

  def method_missing(name, *args, &blk)  # instance's one
    if attrs.keys.include?(name.to_sym)
      attrs[name.to_sym]
    else
      super(name, args, blk)
    end
  end

  def self.included(base)
    base.extend(ClassMethods)

    base.class_eval do
      attr_accessor :attrs  # The same as attributes but is populated with default values instead nils if any
      # set in `set_field_types_and_defaults` class method
      scope :report, from(view)


      # A little bit dirty ( delegating instance methods of class Class ) but useful as hell
      class << self
        delegate :first, :last, :where, :all, :to => :report # essential ones, want to name more? :) Feel free to populate
      end


    end

  end





end