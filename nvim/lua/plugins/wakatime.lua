return {
  {
    "wakatime/vim-wakatime",
    -- WakaTime's setup probes/installs its CLI and is network-bound; keep it
    -- off the measured startup path. It still loads before user interaction.
    event = "VeryLazy",
  },
}
