module ActiveRecordLite
  module Associatable
    class AssocOptions
      attr_accessor(
        :foreign_key,
        :class_name,
        :primary_key
      )

      def model_class
        @class_name.constantize
      end

      def table_name
        model_class.table_name || @class_name.pluralize.downcase.to_s
      end
    end

    def assoc_options
      @assoc_options ||= {}
    end

  end
end
