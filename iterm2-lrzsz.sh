#! /bin/bash --login

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

function cancel_zmodem() {
  echo -e \\x18\\x18\\x18\\x18\\x18 # send zmodem cancel
}

function complete_zmodem() {
  sleep 1 # make echo works
  echo
}

function send() {
  files=$(osascript -l JavaScript -e "
    const app = Application('Iterm2')
    app.includeStandardAdditions = true
    app.chooseFile({
      withPrompt: 'Choose files to send',
      multipleSelectionsAllowed: true,
    }).map(v => v.toString()).join(' ')
  " 2>/dev/null)
  
  if [[ -z $files ]]; then
    cancel_zmodem
    complete_zmodem
  else
    sz $files --escape --binary --bufsize 4096
    complete_zmodem
  fi
}

function recv() {
  folder=$(osascript -l JavaScript -e "
    const app = Application('Iterm2')
    app.includeStandardAdditions = true
    app.chooseFolder({
      withPrompt: 'Choose a folder to place received files in',
    }).toString()
  " 2>/dev/null)

  if [[ -z $folder ]]; then
    cancel_zmodem
    complete_zmodem
  else
    cd $folder
    rz --rename --escape --binary --bufsize 4096
    complete_zmodem
  fi
}

if [[ $1 = 'send' ]]; then
  send
elif [[ $1 = 'recv' ]]; then
  recv
fi