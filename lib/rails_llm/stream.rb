# frozen_string_literal: true

require "llm"

module RailsLLM
  ##
  # {Stream} enriches llm.rb's streaming with structured events
  # for the chat UI. Captures content, reasoning, tool calls,
  # and tool returns as structured events.
  class Stream < LLM::Stream
    attr_reader :reasoning_content, :tool_calls

    def initialize(stream)
      @stream = stream
      @reasoning_content = +""
      @tool_calls = []
      @buffer = +""
    end

    ##
    # @param [String] content
    # @return [void]
    def on_content(content)
      @buffer << content
      write(type: "content", content: RailsLLM.markdown(@buffer))
    end

    ##
    # @param [String] content
    # @return [void]
    def on_reasoning_content(content)
      @reasoning_content << content
    end

    ##
    # @param [LLM::Function] tool
    # @param [String, nil] error
    # @return [void]
    def on_tool_call(tool, error)
      if error
        queue << error
      else
        @tool_calls << {name: tool.name, arguments: tool.arguments}
        write(type: "tool_call", name: tool.name, arguments: tool.arguments)
        queue << ctx.spawn(tool, :call)
      end
    end

    ##
    # @param [LLM::Function] tool
    # @param [LLM::Function::Return] result
    # @return [void]
    def on_tool_return(tool, result)
      write(type: "tool_return", name: tool.name, result: result.value)
    end

    ##
    # @return [void]
    def finish
      write(type: "done")
    end

    private

    def write(payload)
      @stream.write("#{LLM.json.dump(payload)}\n")
    end
  end
end
