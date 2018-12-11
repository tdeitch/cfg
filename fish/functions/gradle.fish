function gradle
  if type -q (git root)/gradlew
    eval (git root)/gradlew $argv
  else if command -sq gradle
    command gradle $argv
  else
    echo "Gradle not found" >&2
    exit 1
  end
end
