module Fiveruns
  
  module Tuneup
    
    class CalculationError < ::RuntimeError; end
    
    class << self
      attr_accessor :javascripts_path
      attr_accessor :stylesheets_path
    end

    def self.record(&block)
      Step.reset!
      root = RootStep.new
      root.record(&block)
      root
    end

    def self.step(name, layer, extras = {}, &block)
      trace = format_caller(caller)
      Step.new(name, layer, extras.merge(:caller => trace), nil).record(&block)
    end

    def self.insert_panel(body, run)
      tag = body[/(<body[^>]*>)/i, 1]
      return body unless tag
      body.sub(tag, panel(run)).sub(/<\/head>/i, head << '</head>')
    end

    def self.head
      %(
        <script src='#{javascripts_path}/init.js' type='text/javascript'></script>
        <link rel='stylesheet' type='text/css' href='#{stylesheets_path}/tuneup.css'/>
      )
    end
    
    def self.format_caller(trace)
      valid_lines = trace.reject { |line| line =~ /fiveruns_tuneup/ }[0,5]
      linked_lines = valid_lines.map { |line| editor_link_line(line) }
      '<pre>%s</pre>' % linked_lines.join("\n")
    end
    
    def self.editor_link_line(line)
      filename, number, extra = line.match(/^(.+?):(\d+):in\b(.*?)/)[1, 2]
      %(<a href='txmt://open/?url=file://%s&line=%d'>%s</a>%s) % [filename, number, line, extra]
    end

    def self.panel(run)
      %(<div id='tuneup'>#{run ? run.to_html : nil}</div>)
    end
 
    class RootStep
      attr_reader :children
      attr_accessor :time
      def initialize(time = nil)
        @time = time
        @children = []
      end
      def record
        start = Time.now
        result = Step.inside(self) { yield }
        @time = Time.now - start
        result
      end
      def disparity
        result = time - children.inject(0) { |sum, child| sum + child.time }
        if result < 0
          raise CalculationError, "Child steps exceed parent step size"
        end
        result
      end
      def add_child(child)
        child.parent = self
        children << child
      end
      def format_time(time)
        '%.1fms' % (time * 1000)
      end
      def to_json
        {:children => children, :time => time}.to_json
      end
      def to_html
        child_tree = if children.any?
          "<ul>%s</ul>" % children.map { |child| child.to_html }.join
        end
        %(<li>#{child_tree}</li>)
      end
    end

    class Step < RootStep

      def self.stack
        @stack ||= []
      end

      def self.reset!
        stack.clear
      end

      def self.inside(step)
        unless stack.empty?
          stack.last.add_child(step)
        end
        stack << step
        result = yield
        stack.pop
        result
      end

      attr_reader :name, :layer
      attr_accessor :parent
      def initialize(name, layer, extras = {}, time = nil)
        super(time)
        @name = name
        @layer = layer
        @extras = extras
      end

      def children_with_disparity
        return children if children.empty?
        layer_name = layer if respond_to?(:layer)
        children + [Step.new('(Other)', layer_name, {}, disparity)]
      end

      def layer_portions
        @layer_portions ||= begin
          result = {:model => 0, :view => 0, :controller => 0}
          if children.empty?
            result[layer] = 1
          else
            times = children.inject({}) do |totals, child|
              totals[child.layer] ||= 0
              totals[child.layer] += child.time
              totals
            end
            times[layer] ||= 0
            times[layer] += disparity
            times.inject(result) do |all, (l, t)|
              result[l] = t / time
              result            
            end
          end
          result
        end
      end
      
      def to_json
        {:children => children_with_disparity, :time => time}.to_json
      end

      def to_html
        child_tree = if children.any?
          "<ul class='children'>%s</ul>" % children_with_disparity.map { |child| child.to_html }.join
        end
        rows = @extras.map { |key, value| %(<tr><th>#{key.to_s.capitalize}</th><td>#{value}</td></tr>)}
        extra_info = %(<a class='details' href='#step-details-#{object_id}'>Details</a><div id='step-details-#{object_id}'><table>%s</table></div>) % rows.join
        parts = [:model, :view, :controller].map do |l|
          if (portion = layer_portions[l]) > 0
            "<li class='mvc %s' title='%f'>%s</li>" % [l, portion, l.to_s[0, 1].upcase]
          end
        end
        bar = "<ul class='bar' title='#{time * 1000}'><li class='time'>#{'%.1f' % (time * 1000)}ms</li>#{parts.compact.join}</ul>"
        %(<li class='#{:parent if children.any?}'>#{bar}<span>#{name}</span>#{child_tree}</li>)
      end

    end
  
  end
      
end