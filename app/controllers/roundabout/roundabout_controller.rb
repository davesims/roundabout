require 'pp'
require 'roundabout/application_controller'
require 'graphviz'

module Roundabout
  class RoundaboutController < ::Roundabout::ApplicationController
    def index
      @transitions = if (json = Rails.root.join('doc/roundabout.json')).exist?
        ActiveSupport::JSON.decode json.read
      else
        []
      end
      GraphViz.new(:G, type: :digraph, rankdir: 'LR') {|g|
        @transitions.each do |t|
          from = g.add_nodes t['from'], shape: 'box'
          to = g.add_nodes t['to'], shape: 'box'
          color = case t['type']
          when 'redirect'
            'red'
          when 'form'
            'purple'
          else
            'blue'
          end
          g.add_edges from, to, color: color
        end
      }.output(png: Rails.root.join('public/images/roundabout.png'))
    end
  end
end
