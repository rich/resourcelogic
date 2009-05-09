module Resourcelogic
  module Scope
    def self.included(klass)
      klass.class_eval do
        add_acts_as_resource_module(Methods)
      end
    end
    
    module Methods
      def self.included(klass)
        klass.class_eval do
          attr_accessor :scoping, :scoping_parent
        end
      end
      
      private
        def scope
          parent? ? parent_object.send(parent_scope_name) : model
        end
        
        def parent_scope
          parent_model
        end
        
        def parent_scope_name
          @parent_scope_name ||= model_name.to_s.pluralize
        end
    end
  end
end       