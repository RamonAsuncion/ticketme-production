#!/bin/bash
if [ -d "$HOME/rpi-rgb-led-matrix" ]; then
  echo "Directory already exists"
  cd ~/rpi-rgb-led-matrix
  git pull
else
  cd ~
  git clone https://github.com/hzeller/rpi-rgb-led-matrix.git
  if [ $? -ne 0 ]; then
    echo "Failed to clone repo"
    exit 1
  fi
  cd rpi-rgb-led-matrix
fi

# make

# if [ $? -ne 0 ]; then
#   echo "Failed to build main library"
#   exit 1
# fi

cd utils
make

if [ $? -ne 0 ]; then
  echo "Failed to build utilities"
  exit 1
fi

echo "Add binary to sudoers file, run: sudo visudo"
echo "Then add this line (replace 'pi' with your raspberry pi username):"
echo "pi ALL=(ALL) NOPASSWD: $HOME/rpi-rgb-led-matrix/utils/text-scroller"
