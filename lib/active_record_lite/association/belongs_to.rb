module ActiveRecordLite
  module Associatable
    def belongs_to(name, options = {})
      self.assoc_options[name] = BelongsToOptions.new(name, options)
      define_method(name) do
        result_options = self.class.assoc_options[name]
        foreign_key = result_options.foreign_key
        result_options.model_class.where(
        result_options.primary_key => self.send(foreign_key)
        ).first
      end
    end
    
    class BelongsToOptions < AssocOptions
      def initialize(name, options = {})
        @foreign_key  = options[:foreign_key] || "#{name}_id".to_sym
        @class_name   = options[:class_name]  || name.to_s.capitalize
        @primary_key  = options[:primary_key] || :id
      end
    end
  end
end
