
return {
  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup({
        provider = "openai_fim_compatible",
        n_completions = 1,
        context_window = 1024,
        debounce = 100,
        throttle = 200,
        request_timeout = 5,

        virtualtext = {
          auto_trigger_ft = { "c", "cpp", "lua", "python", "rust", "js",
            "bash", "sh", "lua", "html"},
          keymap = {
            accept = "<A-a>",
            dismiss = "<A-e>",
          },
        },

        provider_options = {
          openai_fim_compatible = {
            api_key = "TERM",
            name = "Ollama",
            end_point = "http://localhost:11434/v1/completions",
            model = "codegemma-2b-q6-fim",
            optional = {
              max_tokens = 64,
            },
          },
        },
      })
    end,
  },
}
