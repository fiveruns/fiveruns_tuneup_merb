require 'pp'

module FiverunsTuneupMerb
    
  module Instrumentation
    
     def self.pretty(value)
       CGI.escapeHTML(PP.pp(value, ''))
     end
     
     def self.format_filters(filters)
       sets = filters.map do |filter, opts|
         content = if filter.is_a?(Proc)
           where = filter.inspect[/@(.+)>$/, 1]
           "Proc at %s with options %s" % [Fiveruns::Tuneup.editor_link_line(where), pretty(opts)]
         else
           "%s with options %s" % [pretty(filter), pretty(opts)]
          end
         %(<li>%s</li>) % content
       end
       "<ul>%s</ul>" % sets.join("\n")
     end
     
     def self.format_sql(query, statement, attributes = nil)
       values = query.bind_values + (attributes ? attributes.values : [])
       [statement, "<b>Values:</b> " + CGI.escapeHTML(values.inspect)].join("<br/>")
     end
     
     def self.attrs_for(query)
       [
         [ :repository, query.repository.name ],
         [ :model,      query.model           ],
         [ :fields,     query.fields          ],
         [ :links,      query.links           ],
         [ :conditions, query.conditions      ],
         [ :order,      query.order           ],
         [ :limit,      query.limit           ],
         [ :offset,     query.offset          ],
         [ :reload,     query.reload?         ],
         [ :unique,     query.unique?         ]
       ]
     end
     
     def self.format_query(query)
       rows = attrs_for(query).map do |set|
         %(<tr><th>%s</th><td><pre>%s</pre></td></tr>) % set.map { |item|
           pretty item
         }
       end
       "<table>%s</table>" % rows.join
     end

     module Merb

       module Controller

         def new(*args, &block)
           super.extend(Ext)
         end

         module Ext

           def body
             if content_type == :html && request.tuneup
               ::Merb.logger.debug "TuneUp: Saving run and inserting panel into the response (#{request.tuneup.class})"
               run = Fiveruns::Tuneup::Run.new(request.uri, request.tuneup)
               ::Merb.logger.debug "TuneUp: Compressing #{run.to_json.size} bytes of JSON to persist"
               run.save
               Fiveruns::Tuneup.insert_panel(super, request.tuneup)
             else
               super
             end
           end

           def render(thing = nil, *args)
             name = thing ? thing.inspect : nil 
             Fiveruns::Tuneup.step("Render #{name}", :view) { super }
           end

           def partial(template, *args)
             Fiveruns::Tuneup.step("Partial #{template.inspect}", :view) { super }
           end

           def _call_filters(filters)
             if filters.empty?
               super
             else
               Fiveruns::Tuneup.step("Filters (#{filters.size})", :controller, 
                 "Filters Called" => FiverunsTuneupMerb::Instrumentation.format_filters(filters)
               ) { super }
             end
           end

         end

       end

       module Request

         def new(*args, &block)
           request = super
           request.extend(Ext)
           class << request
             attr_reader :tuneup
           end
           request
         end

         module Ext

           def dispatch_action(klass, action, *args, &block)
             controller = nil
             @tuneup = Fiveruns::Tuneup.record do
               controller = Fiveruns::Tuneup.step "Dispatching #{klass}##{action}", :controller do
                 super
               end
             end
             # Don't save redirects from panel insertion
             if controller && controller.headers['Location']
               ::Merb.logger.debug 'TuneUp: Ignoring redirect.'
               @tuneup = nil
             elsif xml_http_request?
               ::Merb.logger.debug 'TuneUp: Ignoring XHR request.'
               @tuneup = nil
             elsif controller.is_a?(FiverunsTuneupMerb::Application)
               ::Merb.logger.debug 'TuneUp: Ignoring internal request.'
               @tuneup = nil
             else
               ::Merb.logger.info 'TuneUp: Valid request.'
             end   
             controller
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
             Fiveruns::Tuneup.step("DM Read Many", :model,
               'Query' => [
                 FiverunsTuneupMerb::Instrumentation.format_sql(query, adapter.send(:read_statement, query)),
                 {'Raw Details' => FiverunsTuneupMerb::Instrumentation.format_query(query)}
               ]
             ) { super }
           end

           def read_one(query)
             Fiveruns::Tuneup.step("DM Read One ", :model,
               'Query' => [
                 FiverunsTuneupMerb::Instrumentation.format_sql(query, adapter.send(:read_statement, query)),
                 {'Raw Details' => FiverunsTuneupMerb::Instrumentation.format_query(query)}
                ]
             ) { super }
           end

           def update(attributes, query)
             Fiveruns::Tuneup.step("DM Update", :model,
               'Query' => [
                 FiverunsTuneupMerb::Instrumentation.format_sql(query, adapter.send(:update_statement, query), attributes),
                 {'Raw Details' => FiverunsTuneupMerb::Instrumentation.format_query(query)}
                ]
             ) { super }
           end

           def delete(query)
             Fiveruns::Tuneup.step("DM Delete", :model,
               'Query' => [
                 FiverunsTuneupMerb::Instrumentation.format_sql(query, adapter.send(:delete_statement, query)),
                 {'Raw Details' => FiverunsTuneupMerb::Instrumentation.format_query(query)}
               ]
             ) { super }
           end

         end

       end

     end

   end
      
end