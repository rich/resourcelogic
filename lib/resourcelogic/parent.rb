module Resourcelogic
  module Parent
    def self.included(klass)
      klass.class_eval do
        extend Config
        add_acts_as_resource_module(Urls)
        add_acts_as_resource_module(Reflection)
      end
    end
    
    module Config
      def belongs_to(name = nil, options = {})
        @belongs_to ||= {}
        if name.nil?
          @belongs_to
        else
          @belongs_to[name.to_sym] = options
        end
      end
      
      def require_parent(value = nil)
        rw_config(:require_parent, value, false)
      end
    end
    
    module Urls
      private
        def parent_url_parts(action = nil, url_params = {})
          [action] + contexts_url_parts + [url_params]
        end
        
        def parent_collection_url_parts(*args)
          parent_url_parts(*args)
        end
    end
    
    module Reflection
      def self.included(klass)
        klass.class_eval do
          helper_method :parent?, :parent_model_name, :parent_object
          before_filter :require_parent
        end
      end
      
      private
        def belongs_to
          self.class.belongs_to
        end
        
        def parent_alias
          return @parent_alias if defined?(@parent_alias)
          parent_from_path?
          @parent_alias
        end
        
        # Returns the type of the current parent
        #
        def parent_model_name
          return @parent_model_name if defined?(@parent_model_name)
          parent_from_path?
          @parent_model_name
        end
        
        def parent_model
          @parent_model ||= parent_model_name.to_s.camelize.constantize
        end
        
        # Returns the type of the current parent extracted form a request path
        #    
        def parent_from_path?
          return @parent_from_path if defined?(@parent_from_path)
          belongs_to.each do |model_name, options|
            request.path.split('/').reverse.each do |path_part|
              ([model_name] + (route_aliases[model_name] || [])).each_with_index do |possible_name, index|
                if [possible_name.to_s, possible_name.to_s.pluralize].include?(path_part)
                  @parent_model_name = model_name
                  @parent_alias = index > 0 ? possible_name : nil
                  return @parent_from_path = true
                end
              end
            end
          end
          @parent_from_path = false
        end
        
        # Returns true/false based on whether or not a parent is present.
        #
        def parent?
          !parent_model_name.nil?
        end
        
        # Returns true/false based on whether or not a parent is a singleton.
        #
        def parent_singleton?
          parent_id.nil?
        end
        
        # Returns the current parent param, if there is a parent. (i.e. params[:post_id])
        def parent_id
          params["#{parent_model_name}_id".to_sym]
        end
        
        # Returns the current parent object if a parent object is present.
        #
        def parent_object
          return @parent_object if defined?(@parent_object)
          if parent?
            if parent_singleton? && respond_to?("current_#{parent_model_name}", true)
              @parent_object = send("current_#{parent_model_name}")
            else
              @parent_object = parent_scope.find(parent_id)
            end
          else
            @parent_object = nil
          end
        end
        
        def require_parent
          raise StandardError.new("A parent is required to access this resource and no parent was found") if !parent? && self.class.require_parent == true
        end
    end
  end
end