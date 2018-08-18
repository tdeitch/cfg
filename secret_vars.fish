function set_var
  if [ (count $argv) -ne 1 ]
    echo "Failed setting $argv: wrong number of arguments!"
    exit 1
  end
  if set -q "$argv"
    echo "$argv already set"
  else
    read -P "Enter $argv: " value_to_set
    set -U "$argv" "$value_to_set"
  end
end

set_var HOMEBREW_GITHUB_API_TOKEN
