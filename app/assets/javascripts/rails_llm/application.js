;(function() {
  const View = (messages) => {
    const append = (role, content) => {
      const node = document.createElement("div")
      node.className = `message ${role}`
      node.textContent = content
      messages.appendChild(node)
      messages.scrollTop = messages.scrollHeight
      return node
    }

    const appendToolCall = (name) => {
      const node = document.createElement("details")
      const summary = document.createElement("summary")
      const label = document.createElement("span")
      node.className = "tool-call live"
      node.open = true
      label.className = "tool-name"
      label.textContent = name
      summary.append("Running ", label)
      node.appendChild(summary)
      messages.appendChild(node)
      messages.scrollTop = messages.scrollHeight
      return node
    }

    return {
      messages,
      appendToolCall,
      appendAssistant() {
        const node = append("assistant", "")
        return node
      },
      appendUser(content) {
        return append("user", content)
      },
      clearEmptyState() {
        const emptyState = messages.querySelector(".empty-state")
        if (emptyState) emptyState.remove()
      },
      focusBottom() {
        messages.scrollTop = messages.scrollHeight
      },
      showCursor(node) {
        node.classList.add("streaming-cursor")
      },
      hideCursor(node) {
        node.classList.remove("streaming-cursor")
      }
    }
  }

  const JSONStream = (response, onEvent) => {
    const reader = response.body.getReader()
    const decoder = new TextDecoder()
    let buffer = ""

    return {
      async read() {
        while (true) {
          const {value, done} = await reader.read()
          buffer += decoder.decode(value || new Uint8Array(), {stream: !done})
          const lines = buffer.split("\n")
          buffer = lines.pop()
          lines.filter(Boolean).forEach((line) => onEvent(JSON.parse(line)))
          if (done) break
        }
        if (buffer.trim()) onEvent(JSON.parse(buffer))
      }
    }
  }

  const Turn = (form, prompt = null) => {
    const view = View(document.getElementById("messages"))
    const input = form.querySelector('input[name="prompt"]')
    const submit = form.querySelector('input[type="submit"], button[type="submit"]')
    const content = (prompt || input.value).trim()
    const state = {
      assistantNode: null,
      done: false
    }

    const ensureAssistantNode = () => {
      state.assistantNode ||= view.appendAssistant()
      view.showCursor(state.assistantNode)
      return state.assistantNode
    }

    const onEvent = (event) => {
      if (event.type == "done") {
        state.done = true
        return
      }
      if (event.type == "content") {
        ensureAssistantNode().innerHTML = event.content || ""
        view.focusBottom()
        return
      }
      if (event.type == "tool_call") {
        view.appendToolCall(event.name || "tool")
      }
    }

    return {
      async submit() {
        if (!content) return
        const formData = new FormData(form)
        view.clearEmptyState()
        formData.set("prompt", content)
        view.appendUser(content)
        input.value = ""
        input.disabled = true
        submit.disabled = true
        try {
          const response = await fetch(form.action, {
            method: form.method || "POST",
            body: formData,
            headers: {
              "Accept": "application/x-ndjson",
              "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
            }
          })
          if (!response.ok || !response.body) throw new Error(`Request failed: ${response.status}`)
          await JSONStream(response, onEvent).read()
        } catch (error) {
          ensureAssistantNode().textContent = "Streaming failed."
          console.error(error)
        } finally {
          if (state.assistantNode) view.hideCursor(state.assistantNode)
          input.disabled = false
          submit.disabled = false
          input.focus()
        }
      }
    }
  }

  const App = () => {
    const onCreate = async (event) => {
      event.preventDefault()
      const form = event.currentTarget
      const input = form.querySelector('input[name="prompt"]')
      const prompt = input.value.trim()
      const response = await fetch(form.action, {
        method: form.method || "POST",
        body: new FormData(form),
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        }
      })
      if (!response.ok) return
      const data = await response.json()
      const url = new URL(data.location, window.location.origin)
      url.searchParams.set("prompt", prompt)
      window.location.assign(url)
    }

    const onAsk = async (event) => {
      event.preventDefault()
      await Turn(event.currentTarget).submit()
    }

    return {
      async onDOMContentLoaded() {
        switch(window.location.pathname) {
          case "/ai/agents": {
            const form = document.getElementById("new-agent-form")
            form.addEventListener("submit", onCreate)
            break
          }
          default: {
            const askForm = document.getElementById("ask-form")
            const prompt = new URLSearchParams(window.location.search).get("prompt")
            askForm.addEventListener("submit", onAsk)
            if (!prompt) return
            window.history.replaceState({}, "", window.location.pathname)
            await Turn(askForm, prompt).submit()
            break
          }
        }
      }
    }
  }

  const app = App()
  document.addEventListener("DOMContentLoaded", app.onDOMContentLoaded)
})();
