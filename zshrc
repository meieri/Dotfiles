# GET MY CHECK
# Export bash path.
export PATH=$HOME/bin:/usr/local/bin:$PATH:$HOME/.rvm/bin
export PATH="/Users/imeier/Library/Python/3.7/bin:$PATH"
# Path to your oh-my-zsh installation.
export ZSH="/Users/imeier/.oh-my-zsh"

# Themes.
# ZSH_THEME="oxide"
ZSH_THEME=powerlevel10k/powerlevel10k

# Case-sensitive completion.
CASE_SENSITIVE="false"

# Automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"


# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  vi-mode
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Setup
eval "$(hub alias -s)"

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export LESS=-RiFX

# Functions

# CD into open finder window
function cdf () {
    local target="$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')" 
    if [ "$target" != "" ]
    then
        cd "$target"
        pwd
    else
        echo "No open Finder windows" >&2
    fi
}

# Source zshrc and unalias
function so () {
    for i in $(alias | awk -F = '{print $1}')
    do
        i=$(echo $i | tr -d \') 
        if [[ $i != "" ]]
        then
            unalias $i
        fi
    done
    source ~/.zshrc
  }

# Edit zshrc so gd fast
function vz
{
    nvim ~/.zshrc
}

# Share a function just like that 
# prints and copys
function share
{
    text=`which $1`
    if [[ -n `echo $text | head -n 1 | grep "aliased to" ` ]]; then
        text=`echo -E "$text" | awk -F "aliased to " '{print $2}'`
        surroundingCharacter=

        if [[ -n `echo -E "$text "| grep \'` ]]; then
            surroundingCharacter="\""
        else
            surroundingCharacter="'"
        fi

        text="$surroundingCharacter$text$surroundingCharacter"
    else
        text="function ${text}"
    fi

    echo -E $text | pbcopy
    echo -E $text
  }

# cd to the folder containing an Xcode project dragged from an Xcode window's proxy icon. If no file is provided, cd to the folder containing the current Xcode project
function cdx
{
    xcodeIsRunning=false
    if [[ `osascript -e 'tell app "System Events" to count processes whose name is "Xcode"'` == 1 ]]; then
        xcodeIsRunning=true
    fi

    if [[ $xcodeIsRunning == false ]]; then
        echo "Xcode is not open. I don't know what you want from me."
        return
    fi

    if [[ -z $1 ]]; then
        filePath="`osascript -e 'tell application "Xcode" to return POSIX path of (get file of front document)'`"
        # TODO: suppress the error here when there are no open documents
        if [[ -z $filePath ]]; then
            echo "Xcode has no open documents."
            return
        fi

        cd "$filePath"
        returnSilentlyIfNotGitRepo
        groot
    else
        filePath="$@"
        cd "$filePath"/..
    fi
  }

# cd to root of current Git repo, if any
function groot
{
    cd "$(git rev-parse --git-dir)/.."
}

# Copies the current Safari and macOS version and build number to the clipboard. Useful for bug reporting.
function copySafariVersion
{
    local safariVersion=$(defaults read /Applications/Safari.app/Contents/Info CFBundleShortVersionString)
    local safariBuild=$(defaults read /Applications/Safari.app/Contents/Info CFBundleVersion)
    local macOSVersion=$(sw_vers -productVersion)
    local macOSBuild=$(sw_vers -buildVersion)
    local fullString="Safari ${safariVersion} (${safariBuild}) on macOS ${macOSVersion} (${macOSBuild})"
    echo "Copied \"$fullString\""
    echo -n $fullString | pbcopy
}

# Copies the current Chrome and macOS version and build number to the clipboard. Useful for bug reporting.
function copyChromeVersion
{
    local chromeVersion=$(defaults read /Applications/Google\ Chrome.app/Contents/Info CFBundleShortVersionString)
    local chromeBuild=$(defaults read /Applications/Google\ Chrome.app/Contents/Info CFBundleVersion)
    local macOSVersion=$(sw_vers -productVersion)
    local macOSBuild=$(sw_vers -buildVersion)
    local fullString="Chrome ${chromeVersion} (${chromeBuild}) on macOS ${macOSVersion} (${macOSBuild})"
    echo "Copied \"$fullString\""
    echo -n $fullString | pbcopy
}

# Copies the current Xcode and macOS version and build number to the clipboard. Useful for bug reporting.
function copyXcodeVersion
{
    local xcodePath=`xcode-select -p | rev | cut -d'/' -f3- | rev`
    local xcodeVersion=$(defaults read "${xcodePath}"/Contents/Info CFBundleShortVersionString)
    local xcodeBuild=$(defaults read "${xcodePath}"/Contents/Developer/Library/Frameworks/XcodeKit.framework/Versions/A/Resources/version ProductBuildVersion)
    local macOSVersion=$(sw_vers -productVersion)
    local macOSBuild=$(sw_vers -buildVersion)
    local fullString="Xcode ${xcodeVersion} (${xcodeBuild}) on macOS ${macOSVersion} (${macOSBuild})"
    echo "Copied \"$fullString\""
    echo -n $fullString | pbcopy
}

# Copies the current macOS version and build number to the clipboard. Useful for bug reporting.
function copymacOSVersion
{
    local macOSVersion=$(sw_vers -productVersion)
    local macOSBuild=$(sw_vers -buildVersion)
    local fullString="macOS ${macOSVersion} (${macOSBuild})"
    echo "Copied \"$fullString\""
    echo -n $fullString | pbcopy
}

# Record video of the iOS simulator.
# Ctrl-C ends recording and dumps the resulting video to the desktop with a similar file name format as a normal screenshot.
function iOSVideo
{
    local dateString=`date +"%Y-%m-%d at %I.%M.%S %p"`
    local fileName="iOS Simulator Video $dateString.mp4"
    local filePath="$HOME/Desktop/$fileName"
    xcrun simctl io booted recordVideo --mask black $filePath
}

# Aliases
alias la='ls -al'
alias c='clear'
alias o='open .'
alias xci='cd ~/Work/XCI/'
alias xcic='cd ~/Work/XCI/XCI-CCIDApp-iOS/'
alias xcib='cd ~/Work/XCI/XCI-BankApp-iOS'
alias xcis='cd ~/Work/XCI/XCI-SDK-iOS'
alias q='nvim ~/Work/XCI/questions'
alias spin='cd ~/Documents/hacking-with-swift/SpinArtV1/'
alias voa='cd ~/Documents/VoiceOfAmerica/'
alias v='open -a macvim'
alias acs='cd ~/Work/agilecraft-script/'

# Used in functions
alias isGitRepo='[[ -n $(git rev-parse --git-dir 2> /dev/null) ]]'
alias returnIfNotGitRepo='if isGitRepo; then; ; else echo "No repositories here."; return 1; fi'
alias returnSilentlyIfNotGitRepo='if isGitRepo; then; ; else return 1; fi'
