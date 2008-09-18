require 'pp'

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
         
       def self.pretty(value)
         CGI.escapeHTML(PP.pp(value, ''))
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
       
       def self.format_sql(query, statement, attributes = nil)
         values = query.bind_values + (attributes ? attributes.values : [])
         [statement, "<b>Values:</b> " + CGI.escapeHTML(values.inspect)].join("<br/>")
       end
       
       def self.format_query(query)
         rows = attrs_for(query).map do |set|
           %(<tr><th>%s</th><td><pre>%s</pre></td></tr>) % set.map { |item| pretty item }
         end
         "<table>%s</table>" % rows.join
       end

       module Repository

         def new(*args, &block)
           super.extend(Ext)
         end

         module Ext

           def read_many(query)
             Fiveruns::Tuneup.step("DM Read Many", :model,
               'Query' => [
                 FiverunsTuneupMerb::Instrumentation::DataMapper.format_sql(query, adapter.send(:read_statement, query)),
                 {'Details' => FiverunsTuneupMerb::Instrumentation::DataMapper.format_query(query)}
               ]
             ) { super }
           end

           def read_one(query)
             Fiveruns::Tuneup.step("DM Read One ", :model,
               'Query' => [
                 FiverunsTuneupMerb::Instrumentation::DataMapper.format_sql(query, adapter.send(:read_statement, query)),
                 {'Details' => FiverunsTuneupMerb::Instrumentation::DataMapper.format_query(query)}
                ]
             ) { super }
           end

           def update(attributes, query)
             Fiveruns::Tuneup.step("DM Update", :model,
               'Query' => [
                 FiverunsTuneupMerb::Instrumentation::DataMapper.format_sql(query, adapter.send(:update_statement, query), attributes),
                 {'Details' => FiverunsTuneupMerb::Instrumentation::DataMapper.format_query(query)}
                ]
             ) { super }
           end

           def delete(query)
             Fiveruns::Tuneup.step("DM Delete", :model,
               'Query' => [
                 FiverunsTuneupMerb::Instrumentation::DataMapper.format_sql(query, adapter.send(:delete_statement, query)),
                 {'Details' => FiverunsTuneupMerb::Instrumentation::DataMapper.format_query(query)}
               ]
             ) { super }
           end

         end

       end

     end

   end
      
end