module AbstractTable


  module ClassMethods

    def columns
      @columns ||= []
    end

    def column(name, sql_type = nil, default = nil, null = true)
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
        delegate :first, :last, :where, :to => :report # You can name more? :) Feel free to populate
      end

    end

  end





end