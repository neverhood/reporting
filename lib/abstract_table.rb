module AbstractTable


    module ClassMethods

      def columns
        @columns ||= []
      end

      def column(name, sql_type = nil, default = nil, null = true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      end

      def fields
        File.open('/home/vlad/check', 'w') {|f| f.puts self::View}
      end

    end

    def method_missing(name, *args, &blk)
      'attributes here'
    end

    def self.included(base)
      base.extend(ClassMethods)
    end





end