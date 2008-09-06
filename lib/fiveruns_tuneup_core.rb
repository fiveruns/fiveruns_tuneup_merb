module Fiveruns
  
  module Tuneup
    
    class CalculationError < ::RuntimeError; end

    def self.record(&block)
      Step.reset!
      root = RootStep.new
      root.record(&block)
      root
    end

    def self.step(name, layer, extras = {}, &block)
      Step.new(name, layer, extras, nil).record(&block)
    end

    def self.insert_panel(body, run)
      tag = body[/(<body[^>]*>)/i, 1]
      return body unless tag
      body.sub(tag, panel(run)).sub(/<\/head>/i, head << '</head>')
    end

    def self.head
      %(
        <script src='/javascripts/jquery.js' type='text/javascript'></script>
        <script src='/javascripts/tuneup.js' type='text/javascript'></script>
        <link rel='stylesheet' type='text/css' href='/stylesheets/tuneup.css'/>
      )
    end

    def self.panel(run)
      %(<div id='tuneup'>#{run}</div>)
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
      def to_s
        child_tree = if children.any?
          "<ul>%s</ul>" % children.map { |child| child.to_s }.join
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

      def to_s
        child_tree = if children.any?
          "<ul class='children'>%s</ul>" % children_with_disparity.map { |child| child.to_s }.join
        end
        extra_info = if !@extras.empty?
          rows = @extras.map { |key, value| %(<tr><th>#{key}</th><td>#{CGI.escapeHTML value.to_s}</td></tr>)}
          %(<table>%s</table>) % rows.join
        end
        parts = [:model, :view, :controller].map do |l|
          if (portion = layer_portions[l]) > 0
            "<li class='mvc' title='%f'>%s</li>" % [portion, l.to_s[0, 1].upcase]
          end
        end
        bar = "<ul class='bar' title='#{time * 1000}'><li class='time'>#{'%.1f' % (time * 1000)}ms</li>#{parts.compact.join}</ul>"
        %(<li>#{bar}<span>#{name}</span>#{extra_info}#{child_tree}</li>)
      end

    end
  
  end
      
end