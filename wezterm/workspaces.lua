local W = {}
local home = os.getenv("HOME") or os.getenv("USERPROFILE")  -- Use HOME or fallback to USERPROFILE

if not home then
  error("Could not determine the home directory. Ensure HOME or USERPROFILE is set.")
end

W.workspaces = {
  default_workspace = "default",
  repositories      = {
    { type = "personal", workspace = "default",  name = "home",     path = home                                                            },
  }
}

return W
