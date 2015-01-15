module ActiveRecordLite
  module Associatable
    def has_many(name, options = {})
      self.assoc_options[name] = HasManyOptions.new(name, self.to_s, options)
      define_method(name) do
        result_options = self.class.assoc_options[name]
        primary_key = result_options.send(:primary_key)
        result_options.model_class.where(
        result_options.send(:foreign_key) => self.send(primary_key)
        )
      end
    end
    
    class HasManyOptions < AssocOptions
      def initialize(name, self_class_name, options = {})
        @foreign_key  = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
        @class_name   = options[:class_name]  || name.to_s.capitalize.singularize
        @primary_key  = options[:primary_key] || :id
      end
    end
  end
end
