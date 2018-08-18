# Environment
export PATH=$HOME/bin:$PATH
export EDITOR='vim'
REPORTTIME=3

# fasd
eval "$(fasd --init auto)"
alias e="fasd -e $EDITOR"

# Java
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_7_HOME=$(/usr/libexec/java_home -v1.7)
export JAVA_HOME=$JAVA_8_HOME
export GRADLE_OPTS='-Djavax.net.ssl.trustStore=$(/usr/libexec/java_home)/jre/lib/security/cacerts '\
'-Djavax.net.ssl.trustStorePassword=changeit '\
'-Djavax.net.ssl.keyStore=$(/usr/libexec/java_home)/jre/lib/security/cacerts '\
'-Djavax.net.ssl.keyStorePassword=changeit'
alias java7='export JAVA_HOME=$JAVA_7_HOME'
alias java8='export JAVA_HOME=$JAVA_8_HOME'

# Go
export GOPATH=$HOME/Code/gowork

# Homebrew
export HOMEBREW_NO_AUTO_UPDATE="1"
export PATH="/usr/local/sbin:$PATH"

# Secrets
source .zsh_secrets

# Node
eval "$(nodenv init -)"

