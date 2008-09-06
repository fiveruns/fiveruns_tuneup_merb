module FiverunsTuneupMerb
    
  module Instrumentation

     module Merb

       module Controller

         def new(*args, &block)
           super.extend(Ext)
         end

         module Ext

           def body
             if content_type == :html
               Fiveruns::Tuneup.insert_panel(super, request.tuneup_run)
             else
               super
             end
           end

           def render(thing, *args)
             Fiveruns::Tuneup.step("Render #{thing.inspect}", :view) { super }
           end

           def partial(template, *args)
             Fiveruns::Tuneup.step("Partial #{template.inspect}", :view) { super }
           end

           def _call_filters(filters)
             if filters.empty?
               super
             else
               Fiveruns::Tuneup.step("Called filters (#{filters.size})", :controller) { super }
             end
           end

         end

       end

       module Request

         def new(*args, &block)
           request = super
           request.extend(Ext)
           class << request
             attr_reader :tuneup_run
           end
           request
         end

         module Ext

           def dispatch_action(controller, action, *args, &block)
             result = nil
             @tuneup_run = Fiveruns::Tuneup.record do
               result = Fiveruns::Tuneup.step "Dispatching #{controller}##{action}", :controller do
                 super
               end
             end
             result
           end

         end

       end

     end

     module DataMapper

       module Repository

         def new(*args, &block)
           super.extend(Ext)
         end

         module Ext

           def read_many(query)
             Fiveruns::Tuneup.step("DM Read Many", :model, :repository => @name, :query => query.inspect) { super }
           end

           def read_one(query)
             Fiveruns::Tuneup.step("DM Read One", :model, :repository => @name, :query => query.inspect) { super }
           end

           def update(attributes, query)
             Fiveruns::Tuneup.step("DM Update", :model, :repository => @name, :query => query.inspect) { super }
           end

           def delete(query)
             Fiveruns::Tuneup.step("DM Delete", :model, :repository => @name, :query => query.inspect) { super }
           end

         end

       end

     end

   end
      
end