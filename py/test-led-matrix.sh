echo "This is a test!" > ~/text-to-display.txt
cd ~/rpi-rgb-led-matrix/utils
sudo ./text-scroller -f ../fonts/9x18.bdf -i ~/text-to-display.txt --led-rows=64 --led-cols=64 -y 22 -C 255,0,255 -B 0,50,0

if [ $? -ne 0 ]; then
  echo "Test failed. Check error message"
  exit 1
fi