# Nested and Polymorphic Resource Helpers
#
module Resourcelogic
  module Singleton
    def self.included(klass)
      klass.class_eval do
        add_acts_as_resource_module(Methods)
      end
    end
    
    module Methods
      def object
        return @object if defined?(@object)
        
        if singleton?
          if !parent? && respond_to?("current_#{model_name}", true)
            @object = send("current_#{model_name}")
          elsif parent? && parent_object.send(model_name)
            @object = parent_object.send(model_name)
          else
            super
          end
        else
          super
        end
      end
      
      def build_object
        if singleton? && parent?
          scope.send("build_#{model_name}")
        else
          super
        end
      end
      
      def scope
        if singleton? && parent?
          parent_object
        else
          super
        end
      end
      
      def object_url_parts(action = nil, *alternate_object_or_params)
        singleton? ? ([action] + contexts_url_parts + [model_name]) : super
      end
      
      # Override me with true to make singleton
      def singleton?
        false
      end
    end
  end
end
