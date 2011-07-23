module AbstractTable


  module ClassMethods

    def columns # Dear Rails, please don't complain
      @columns ||= []
    end

    def field_types # We are going to need this for fields and filters selections
      attributes = self.first.attributes.to_options
      attributes
      Hash[
          attributes.keys.map do |attribute|
            [attribute,
             case attributes[attribute].class.name
               when 'Fixnum' then :numeric
               when ('String' || 'Symbol') then :varchar
               when ('Date') then :datetime
               when ('Time') then :time
               when ('Datetime') then :datetime
               else
                 nil
             end
            ]
          end
      ]
    end

    def column(name, sql_type = nil, default = nil, null = true) # Dear Rails, please don't complain
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
    end

    def view
      self::VIEW
    end

  end

  def method_missing(name, *args, &blk)  # instance's one
    if attributes.keys.map(&:to_sym).include?(name.to_sym)
      attributes[name.to_sym]
    else
      super(name, args, blk)
    end
  end

  def self.included(base)
    base.extend(ClassMethods)

    base.class_eval do
      scope :report, from(view)

      # A little bit dirty ( delegating instance methods of class Class ) but useful as hell
      class << self
        delegate :first, :last, :where, :to => :report # essential ones, want to name more? :) Feel free to populate
      end

    end

  end





end