module Resourcelogic
  class ResponseSelector
    attr_accessor :context, :default_options, :context_options
    
    def initialize(context, default_options, context_options)
      self.context = context
      self.default_options = default_options
      self.context_options = context_options
    end
    
    def response
      (self.default_options.response + self.context_options.response).inject({}) do |h, v|
        h[v.first] = v.last
        h
      end.to_a
    end
    
    def before
      self.context_options.before || self.default_options.before
    end
    
    def after
      self.context_options.after || self.default_options.after
    end
    
    def flash
      self.context_options.flash || self.default_options.flash
    end
    
    def flash_now
      self.context_options.flash_now || self.default_options.flash_now
    end
  end
end