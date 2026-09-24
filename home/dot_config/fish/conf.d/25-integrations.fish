# Integrations with tools that may not be installed on every machine

if command -q direnv
    direnv hook fish | source
end
