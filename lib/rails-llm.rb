# frozen_string_literal: true

module RailsLLM
  extend self

  require "rails"
  require "llm"
  require "redcarpet"
  require "active_support/inflector"
  require_relative "rails_llm/version"
  require_relative "rails_llm/stream"
  require_relative "rails_llm/engine"

  ##
  # @param [String] text
  # @return [String]
  def markdown(text)
    renderer.render(text)
  end

  ##
  # @return [Redcarpet::Markdown]
  def renderer
    @renderer ||= Redcarpet::Markdown.new(
      Renderer,
      fenced_code_blocks: true,
      tables: true
    )
  end

  ##
  # @api private
  class Renderer < Redcarpet::Render::HTML
    def block_code(code, language)
      language = language.to_s.strip
      klass = language.empty? ? nil : "language-#{language}"
      code = ERB::Util.html_escape(code)
      if klass
        %(<pre><code class="#{klass}">#{code}</code></pre>)
      else
        %(<pre><code>#{code}</code></pre>)
      end
    end
  end

  ActiveSupport::Inflector.inflections(:en) { _1.acronym "LLM" }
end
