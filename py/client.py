# AI Generated with ChatGPT with modifications made by Ramon.
# Docs: https://websocket-client.readthedocs.io/en/latest/examples.html
from typing import Optional, Any, Dict
import websocket
import threading
import json
import time
import subprocess
import os
import uuid
from pynput import keyboard

clear = lambda: os.system("clear")


class KeyboardController:
    def __init__(self, handler, mac_address):
        self.handler = handler
        self.mac_address = mac_address
        self.listener = None
        self.active = False

    def on_press(self, key):
        self.handler.debug_log(f"Key pressed: {key}")
        try:
            # Handle keypad digits (0-9)
            if hasattr(key, "char"):
                if key.char in "0123456789":
                    self.handler.debug_log(f"Keypad digit pressed: {key.char}")
                    self.handler.send_message(
                        "keypad-press",
                        {"mac_address": self.mac_address, "key": key.char},
                    )
                # Handle special keypad keys
                elif key.char == "*":  # Clear
                    self.handler.debug_log("Keypad clear pressed")
                    self.handler.send_message(
                        "keypad-clear", {"mac_address": self.mac_address}
                    )
                elif key.char == "#":  # Submit
                    self.handler.debug_log("Keypad submit pressed")
                    self.handler.send_message(
                        "keypad-submit", {"mac_address": self.mac_address}
                    )
                # Regular keyboard input handling
                else:
                    self.handler.send_message(
                        "keyboard_input",
                        {"mac_address": self.mac_address, "text": key.char},
                    )
            # Handle special keys
            elif key == keyboard.Key.space:
                self.handler.send_message(
                    "keyboard_input", {"mac_address": self.mac_address, "text": " "}
                )
            elif key == keyboard.Key.enter:
                self.handler.send_message(
                    "keyboard_input", {"mac_address": self.mac_address, "text": "\n"}
                )
            elif key == keyboard.Key.backspace:
                self.handler.send_message(
                    "keyboard_input", {"mac_address": self.mac_address, "text": "\b"}
                )
            elif key == keyboard.Key.esc:
                # I have a dual handling system for ESC. I am handling it in
                # the browser side (javascript) and in the client side (python).
                self.handler.send_message(
                    "keyboard_input",
                    {"mac_address": self.mac_address, "text": "EXIT_KEYBOARD_MODE"},
                )
                self.stop()
                return False
        except AttributeError:
            # Handle other key events if needed
            pass

    def on_release(self, key):
        # NOTE: Handled by front end check keyboard_controller.js. DO NOT REMOVE FUNCTION.
        pass

    def start(self):
        """Start keyboard listening in non-blocking mode"""
        if self.active:
            self.handler.debug_log("Keyboard already active")
            return

        self.handler.debug_log("Starting keyboard listener...", True)
        self.active = True
        self.listener = keyboard.Listener(
            on_press=self.on_press, on_release=self.on_release
        )
        self.listener.start()
        self.handler.debug_log("Keyboard listener started", True)

    def stop(self):
        """Stop the keyboard listener"""
        if self.listener and self.active:
            self.handler.debug_log("Stopping keyboard listener...", True)
            self.listener.stop()
            self.active = False
            self.handler.debug_log("Keyboard listener stopped", True)
        else:
            self.handler.debug_log("Keyboard not active, nothing to stop")


class KeypadController:
    def __init__(self, handler, mac_address):
        self.handler = handler
        self.mac_address = mac_address
        self.current_input = ""
        self.active = False
        self.thread = None

        try:
            import digitalio
            import board
            import adafruit_matrixkeypad

            # Define keypad rows and columns
            rows = [
                digitalio.DigitalInOut(x)
                for x in (board.D6, board.D13, board.D19, board.D26)
            ]
            cols = [
                digitalio.DigitalInOut(x)
                for x in (board.D12, board.D16, board.D20, board.D21)
            ]
            keys = (("#", 3, 6, 9), ("D", "A", "B", "C"), (0, 2, 5, 8), ("*", 1, 4, 7))

            self.keypad = adafruit_matrixkeypad.Matrix_Keypad(rows, cols, keys)
            self.handler.debug_log("Hardware keypad initialized successfully", True)

        except ImportError as e:
            self.handler.debug_log(
                f"Error: Hardware keypad libraries not available: {e}", True
            )
            raise ImportError(f"Required keypad libraries not available: {e}")
        except Exception as e:
            self.handler.debug_log(f"Error initializing hardware keypad: {e}", True)
            raise RuntimeError(f"Failed to initialize hardware keypad: {e}")

    def start(self):
        """Start the keypad controller"""
        if self.active:
            self.handler.debug_log("Keypad already active")
            return

        self.active = True
        self.handler.debug_log("Keypad controller activated", True)

        # Start keypad monitoring thread
        self.thread = threading.Thread(target=self._monitor_keypad, daemon=True)
        self.thread.start()

    def stop(self):
        """Stop the keypad controller"""
        self.active = False
        if self.thread:
            self.thread.join(timeout=1.0)
        self.handler.debug_log("Keypad controller stopped", True)

    def send_key_press(self, key):
        """Send a keypad key press to the server"""
        if not self.active:
            return

        self.handler.send_message(
            "keypad-press", {"mac_address": self.mac_address, "key": key}
        )
        self.handler.debug_log(f"Keypad key pressed: {key}")

    def send_clear(self):
        """Send a clear signal"""
        if not self.active:
            return

        self.handler.send_message("keypad-clear", {"mac_address": self.mac_address})
        self.handler.debug_log("Keypad cleared")

    def send_submit(self):
        """Send a submit signal"""
        if not self.active:
            return

        self.handler.send_message("keypad-submit", {"mac_address": self.mac_address})
        self.handler.debug_log("Keypad submitted")

    def _monitor_keypad(self):
        """Monitor physical keypad for key presses"""
        last_keys = []

        while self.active:
            try:
                keys = self.keypad.pressed_keys

                # Only process keys that are newly pressed
                if keys and keys != last_keys:
                    self.handler.debug_log(f"Keypad pressed: {keys}")
                    for key in keys:
                        self.send_key_press(key)

                    # Submit when "#" is pressed
                    if "#" in keys:
                        time.sleep(0.2)  # Debounce
                        self.send_submit()

                    # Clear when "*" is pressed
                    elif "*" in keys:
                        time.sleep(0.2)  # Debounce
                        self.send_clear()

                last_keys = keys

                time.sleep(0.12)  # Polling interval

            except Exception as e:
                self.handler.debug_log(f"Error reading from keypad: {str(e)}", True)
                time.sleep(1.0)


class EnvironmentalSensorController:
    def __init__(self, handler, mac_address):
        self.handler = handler
        self.mac_address = mac_address
        self.active = False
        self.thread = None
        self.wait = 2.0  # seconds between readings

        # Sensor configuration with metadata
        self.sensors = {
            "temp": {
                "name": "Temperature",
                "unit": "°C",
                "color": "#FF4500",
            },
            "humidity": {
                "name": "Humidity",
                "unit": "%",
                "color": "#4169E1",
            },
        }

        # Initialize temperature/humidity sensor
        try:
            import board
            import adafruit_ahtx0

            # temperature/humidity sensor setup
            self.i2c = (
                board.I2C()
            )  # sets up sensor to use SCL and SDA pins on the breakout board
            self.tempHumidity = adafruit_ahtx0.AHTx0(self.i2c)
            self.handler.debug_log(
                "Temperature/humidity sensor initialized successfully", True
            )
        except ImportError as e:
            self.handler.debug_log(
                f"Error: Required temperature sensor libraries not available: {e}", True
            )
            raise ImportError(f"Required sensor libraries not available: {e}")
        except Exception as e:
            self.handler.debug_log(
                f"Error initializing temperature/humidity sensor: {e}", True
            )
            raise RuntimeError(f"Failed to initialize temperature/humidity sensor: {e}")

    def start(self):
        """Start sensor data collection"""
        if self.active:
            self.handler.debug_log("Sensor monitoring already active")
            return

        self.active = True
        self.thread = threading.Thread(target=self._collect_data, daemon=True)
        self.thread.start()
        self.handler.debug_log("Sensor monitoring started", True)

    def stop(self):
        """Stop sensor data collection"""
        if not self.active:
            self.handler.debug_log("Sensor monitoring not active")
            return

        self.active = False
        if self.thread:
            self.thread.join(timeout=1.0)
        self.handler.debug_log("Sensor monitoring stopped", True)

    def _collect_data(self):
        """Collect sensor data and send to server"""
        while self.active:
            try:
                timestamp = time.time()
                readings = {}

                # Get actual readings from the hardware sensor
                readings["temp"] = round(self.tempHumidity.temperature, 1)
                readings["humidity"] = round(self.tempHumidity.relative_humidity, 1)
                self.handler.debug_log(
                    f"Sensor readings - Temp: {readings['temp']}°C, Humidity: {readings['humidity']}%"
                )

                data = {
                    "timestamp": timestamp,
                    "readings": readings,
                    "sensors": {
                        k: {key: v[key] for key in ["name", "unit", "color"]}
                        for k, v in self.sensors.items()
                    },
                }

                self.handler.send_message(
                    "sensor_data", {"mac_address": self.mac_address, "data": data}
                )

                time.sleep(self.wait)

            except Exception as e:
                self.handler.debug_log(f"Error collecting sensor data: {str(e)}", True)
                time.sleep(1.0)


class LEDMatrixController:
    home_dir = os.path.expanduser("~")

    def __init__(self):
        self.process = None
        self.matrix_path = f"{self.home_dir}/rpi-rgb-led-matrix"
        self.scroller_path = f"{self.matrix_path}/utils/text-scroller"
        self.temp_file = f"{self.home_dir}/text-to-display.txt"

        # print(self.matrix_path)
        # print(self.scroller_path)
        # print(self.temp_file)

    def _stop_current_display(self):
        """Stop current running display process (similar to Ctrl + C)"""
        if self.process and self.process.poll() is None:  # child is running
            try:
                self.process.terminate()  # SIGTERM
                self.process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                self.process.kill()  # SIGKILL
            self.process = None

    def display_text(self, text, options=None):
        """Display text on LED matrix

        Args:
            text: The text being written to the device.
            options: Additional flags for the led matrix screen.
        """
        if not os.path.exists(self.scroller_path):
            return (False, f"Error: Binary not found: {self.scroller_path}")

        if options is None:
            options = {}

        try:
            with open(self.temp_file, "w") as f:
                f.write(text)
        except Exception as e:
            return (False, f"Failed to write to text file: {str(e)}")

        # sudo ./text-scroller -f ../fonts/9x18.bdf -i ~/repositories/ticketme/py/textToScroll.txt --led-rows=64 --led-cols=64 -y 22 -C 255,0,255 -B 0,50,0
        cmd = [
            "sudo",
            self.scroller_path,
            "-f",
            f"{self.matrix_path}/fonts/{options.get('font', '9x18.bdf')}",
            "-i",
            self.temp_file,
            "--led-rows",
            str(options.get("rows", 64)),
            "--led-cols",
            str(options.get("cols", 64)),
            "-s",
            str(options.get("speed", 0)),
            "-y",
            str(options.get("y_pos", 22)),
        ]

        if "text_color" in options:
            cmd.extend(["-C", options["text_color"]])
        if "bg_color" in options:
            cmd.extend(["-B", options["bg_color"]])

        self._stop_current_display()

        try:
            self.process = subprocess.Popen(
                cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE
            )

            time.sleep(0.5)  # wait a bit to check for errors

            if self.process.poll() is not None:  # process terminated
                stderr = self.process.stderr.read().decode("utf-8")
                return (False, f"Display process failed to start: {stderr}")

            return (True, "Display updated successfully")
        except Exception as e:
            return (False, f"Error starting display process {str(e)}")


class Settings:
    DEFAULT_CONFIG = {
        "ws_host": "localhost",
        "ws_port": "4000",
        "ws_path": "/socket/websocket",
        "mac_address": "",
        "debug_mode": False,
    }
    CONFIG_FILE = "device_config.json"

    def __init__(self) -> None:
        self.config = self.load_config()

    def load_config(self) -> Dict:
        """
        Load the users configuration file if can't be found use default.

        Returns:
            dict: The configuration file.
        """
        try:
            if os.path.exists(self.CONFIG_FILE) and os.path.isfile(self.CONFIG_FILE):
                with open(self.CONFIG_FILE, "r") as f:
                    return json.load(f)
        except Exception as e:
            print(f"Error loading config: {e}")
        return self.DEFAULT_CONFIG.copy()

    def save_config(self) -> bool:
        """
        Save the users configuration to config file.

        Returns:
            bool: True if the file successfully saved, else False
        """
        try:
            with open(self.CONFIG_FILE, "w") as f:
                json.dump(self.config, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving config: {e}")
            return False


class Menu:
    def __init__(self) -> None:
        """Initialize a new Menu instance."""
        self.settings = Settings()
        self.config = self.settings.load_config()
        self.mac_address = Client.get_mac_address()
        self.error_message = None

    def display_menu(self):
        """Display the main menu to the user."""
        clear()
        if self.error_message:
            print(f"\033[91mError: {self.error_message}\033[0m")

        host = self.config["ws_host"]
        protocol = "ws" if host == "localhost" else "wss"
        default_port = "80" if protocol == "ws" else "443"

        print("Device configuration:")
        print(f"1. Host (current: {self.config['ws_host']})")
        print(
            f"2. Port (current: {self.config['ws_port'] if self.config['ws_port'] else f'Default ({default_port})'})"
        )
        print(f"3. WebSocket Path (current: {self.config['ws_path']})")
        print(
            f"4. Device ID (current: {self.mac_address if self.config['mac_address'] == '' else self.config['mac_address']})"
        )
        print(f"5. Debug Mode (current: {self.config['debug_mode']})")
        print("6. Save and Run")
        print("7. Quit")
        print("\n" + "-" * 10)

    def main_menu(self) -> dict:
        """
        Handle user input.

        Returns:
            dict: The json config
        """
        while True:
            if os.path.isfile(self.settings.CONFIG_FILE):
                print(f"Using {self.settings.CONFIG_FILE}.")
                return self.config

            self.display_menu()

            try:
                choice = input("Enter your choice: ")
                if not choice.isdigit() or int(choice) < 1 or int(choice) > 6:
                    self.error_message = f"invalid choice: '{choice}'"
                    continue

                choice = int(choice)

                if choice == 1:
                    host = input("Enter host: ").strip()
                    old_host = self.config["ws_host"]
                    self.config["ws_host"] = host if host else "localhost"

                    if self.config["ws_host"] != "localhost":
                        self.config["ws_port"] = "443"

                        if ".edu" in self.config["ws_host"]:
                            if not self.config["ws_path"].startswith("/csci379-25s-y"):
                                self.config["ws_path"] = (
                                    "/csci379-25s-y" + self.config["ws_path"]
                                )
                    else:
                        self.config["ws_port"] = "4000"
                        if self.config["ws_path"].startswith("/csci379-25s-y"):
                            self.config["ws_path"] = self.config["ws_path"].replace(
                                "/csci379-25s-y", ""
                            )

                    self.display_menu()
                elif choice == 2:
                    port_input = input("Enter port (leave empty for default): ").strip()
                    if not port_input:
                        self.config["ws_port"] = ""
                    else:
                        try:
                            port = int(port_input)
                            if 1 <= port <= 2**16:
                                self.config["ws_port"] = str(port)
                            else:
                                self.error_message = f"invalid port: '{port}'"
                        except ValueError:
                            self.error_message = f"invalid port: '{port_input}'"
                elif choice == 3:
                    ws_path = input("Enter WebSocket path: ").strip()
                    if ws_path:
                        if not ws_path.startswith("/"):
                            ws_path = f"/{ws_path}"
                        self.config["ws_path"] = ws_path
                    else:
                        self.config["ws_path"] = "/socket/websocket"
                elif choice == 4:
                    mac_address = input(f"Enter device ID: ").strip()
                    self.config["mac_address"] = (
                        mac_address if mac_address else self.mac_address
                    )
                elif choice == 5:
                    self.config["debug_mode"] = not self.config["debug_mode"]
                elif choice == 6:
                    if not self.config["mac_address"]:
                        self.config["mac_address"] = self.mac_address

                    clear()
                    self.settings.config = self.config
                    if self.settings.save_config():
                        return self.config
                    else:
                        self.error_message = "Failed to save configuration"
                elif choice == 7:
                    print("\nExiting...")
                    exit(0)
            except KeyboardInterrupt:
                print("\nExiting...")
                exit(0)


class Client:
    HEARTBEAT_INTERVAL = 10
    COMMAND_TIME_OUT = 10
    LED_PIN = 18  # Using GPIO18 (Pin 12)

    def __init__(self, config: dict) -> None:
        self.mac_address: str = config["mac_address"]
        self.debug: bool = config["debug_mode"]

        self.webcam_running = False

        # Connection info
        host: str = config["ws_host"]
        protocol: str = "ws" if host == "localhost" else "wss"
        port: Optional[int] = config["ws_port"]
        ws_path: str = config["ws_path"]

        if config["ws_port"]:
            port = int(config["ws_port"])
            if (protocol == "ws" and port != 80) or (protocol == "wss" and port != 443):
                self.websocket_url = f"{protocol}://{host}:{port}{ws_path}"
            else:
                self.websocket_url = f"{protocol}://{host}{ws_path}"
        else:
            self.websocket_url = f"{protocol}://{host}{ws_path}"

        self.debug_log(f"WebSocket URL: {self.websocket_url}")

        # Initialize WebSocket handler
        self.handler = WebSocketHandler(
            url=self.websocket_url,
            mac_address=self.mac_address,
            debug_callback=self.debug_log,
            on_connected=self.on_connected,
            on_disconnected=self.on_disconnected,
            on_joined=self.on_joined,
            on_command=self.execute_command,
        )

        # Handle the modules
        self.matrix_controller = LEDMatrixController()
        self.keyboard_controller = KeyboardController(self.handler, self.mac_address)
        try:
            self.sensor_controller = EnvironmentalSensorController(
                self.handler, self.mac_address
            )
            self.has_sensors = True
        except Exception as e:
            self.debug_log(f"Sensor controller not available: {str(e)}", True)
            self.has_sensors = False

        try:
            self.keypad_controller = KeypadController(self.handler, self.mac_address)
            self.has_keypad = True
        except Exception as e:
            self.debug_log(f"Hardware keypad not available: {str(e)}", True)
            self.has_keypad = False

    @property
    def connected(self) -> bool:
        return self.handler.connected if hasattr(self.handler, "connected") else False

    @staticmethod
    def get_mac_address():
        # https://www.geeksforgeeks.org/extracting-mac-address-using-python/
        """Get the MAC address of the device to use as a default device ID."""
        mac = ":".join(
            [
                "{:02x}".format((uuid.getnode() >> elements) & 0xFF)
                for elements in range(0, 8 * 6, 8)
            ][::-1]
        )
        return mac

    def debug_log(self, message: str, ignore_flag: bool = False) -> None:
        """Output debug logs if debug mode is enabled or ignore_flag is True"""
        if self.debug or ignore_flag:
            print(f"debug: {message}")

    def stream_webcam(self):
        """Stream webcam feed through WebSocket."""
        try:
            import cv2
            import base64
            import time
        except ImportError:
            self.debug_log("Error: Missing cv2", True)
            self.handler.send_message(
                "command_result",
                {
                    "mac_address": self.mac_address,
                    "result": "Error: Missing required libraries for webcam",
                },
            )
            return

        # TODO: Probably increment in the webpag.e
        cap = cv2.VideoCapture(0)  # USB camera (device 0)
        frame_count = 0

        if not cap.isOpened():
            self.debug_log("Error: Unable to access the webcam.", True)
            self.handler.send_message(
                "command_result",
                {
                    "mac_address": self.mac_address,
                    "result": "Error: Unable to access webcam",
                },
            )
            return

        try:
            # https://base64.guru/developers/python
            # https://github.com/tobybreckon/python-examples-ip/blob/master/jpeg_compression_noise.py
            self.webcam_running = True

            while self.connected and self.webcam_running:
                ret, frame = cap.read()
                if not ret:
                    self.debug_log("Error: Failed to capture frame.")
                    time.sleep(0.5)
                    continue

                frame_count += 1
                if frame_count % 30 == 0:
                    self.debug_log(f"Webcam streaming: {frame_count} frames sent", True)

                frame = cv2.resize(frame, (640, 480))
                # JPEG 70% quality
                _, buffer = cv2.imencode(".jpg", frame, [cv2.IMWRITE_JPEG_QUALITY, 70])
                frame_base64 = base64.b64encode(buffer).decode("utf-8")

                # Send frame to server
                self.handler.send_message(
                    "webcam_frame",
                    {"frame": frame_base64, "mac_address": self.mac_address},
                )

                # Max of 10FPS
                time.sleep(0.1)

        except Exception as e:
            self.debug_log(f"Webcam streaming error: {str(e)}", True)
            self.handler.send_message(
                "command_result",
                {
                    "mac_address": self.mac_address,
                    "result": f"Webcam error: {str(e)}",
                },
            )
        except KeyboardInterrupt:
            self.debug_log("Webcam streaming stopped")
        finally:
            cap.release()
            self.webcam_running = False
            self.debug_log("Webcam stream stopped", True)

    def connect(self) -> None:
        """Start WebSocket connection"""
        self.handler.connect(trace=self.debug)

    def on_connected(self) -> None:
        """Callback when WebSocket connection is established"""
        self.debug_log("Device connected to server", True)
        # threading.Thread(target=self.stream_webcam, daemon=True).start()

    def on_disconnected(self) -> None:
        """Callback when WebSocket connection is lost"""
        self.debug_log("Device disconnected from server", True)
        self.send_system_log(f"Device {self.mac_address} disconnected")
        self.update_device_status("offline")

    def on_joined(self) -> None:
        """Callback when device successfully joins Phoenix channel"""
        self.update_device_status("online")
        self.send_system_log(f"Device {self.mac_address} online")

    def update_device_status(self, status: str) -> None:
        """Update device status on the server"""
        self.handler.send_message(
            "device_status", {"mac_address": self.mac_address, "status": status}
        )

    def send_system_log(self, message: str) -> None:
        """Send system log message to server"""
        self.handler.send_message(
            "system_log", {"mac_address": self.mac_address, "message": message}
        )

    def execute_command(self, command: str) -> None:
        """Execute command received from server"""
        try:
            self.debug_log(f"Received command: {command}", True)
            if command == "start_keypad":
                self.debug_log("Starting keypad controller", True)
                self.keypad_controller.start()
                self.handler.send_message(
                    "command_result",
                    {
                        "mac_address": self.mac_address,
                        "result": "Keypad controller activated",
                    },
                )
                return
            elif command == "stop_keypad":
                self.debug_log("Stopping keypad controller", True)
                self.keypad_controller.stop()
                self.handler.send_message(
                    "command_result",
                    {
                        "mac_address": self.mac_address,
                        "result": "Keypad controller deactivated",
                    },
                )
                return
            elif command == "start_webcam":
                self.debug_log("Starting webcam stream", True)
                if not self.webcam_running:
                    import threading

                    threading.Thread(target=self.stream_webcam, daemon=True).start()
                else:
                    self.debug_log("Webcam already running", True)

                self.handler.send_message(
                    "command_result",
                    {
                        "mac_address": self.mac_address,
                        "result": "Webcam streaming started",
                    },
                )
                return
            elif command == "stop_webcam":
                self.debug_log("Stopping webcam stream", True)
                self.webcam_running = False
                self.handler.send_message(
                    "command_result",
                    {
                        "mac_address": self.mac_address,
                        "result": "Webcam streaming stopped",
                    },
                )
                return

            if command == "start_keypad":
                self.debug_log("Starting keypad controller", True)
                if self.has_keypad:
                    self.keypad_controller.start()
                else:
                    # Use keyboard controller instead for keypad input
                    self.keyboard_controller.start()
                    self.debug_log(
                        "Using keyboard for keypad input (hardware keypad not available)",
                        True,
                    )

                self.handler.send_message(
                    "command_result",
                    {
                        "mac_address": self.mac_address,
                        "result": "Keypad controller activated",
                    },
                )
                return
            elif command == "stop_keypad":
                self.debug_log("Stopping keypad controller", True)
                if self.has_keypad:
                    self.keypad_controller.stop()
                else:
                    # Stop the keyboard if we're using it for keypad input
                    self.keyboard_controller.stop()

                self.handler.send_message(
                    "command_result",
                    {
                        "mac_address": self.mac_address,
                        "result": "Keypad controller deactivated",
                    },
                )
                return
            elif command == "start_sensors":
                self.debug_log("Starting sensor monitoring", True)
                if self.has_sensors:
                    self.sensor_controller.start()
                    self.handler.send_message(
                        "command_result",
                        {
                            "mac_address": self.mac_address,
                            "result": "Sensor monitoring started",
                        },
                    )
                else:
                    self.handler.send_message(
                        "command_result",
                        {
                            "mac_address": self.mac_address,
                            "result": "Sensor hardware not available on this device",
                        },
                    )
                return
            elif command == "stop_sensors":
                self.debug_log("Stopping sensor monitoring", True)
                if self.has_sensors:
                    self.sensor_controller.stop()

                self.handler.send_message(
                    "command_result",
                    {
                        "mac_address": self.mac_address,
                        "result": "Sensor monitoring stopped",
                    },
                )
                return

            elif (
                command.startswith("led_control:")
                or command.startswith("relay_control:")
                or command.startswith("buzzer_control:")
            ):
                try:
                    _, accessory_id, state = command.split(":")
                    accessory_type = command.split("_")[0]

                    self.debug_log(
                        f"Setting {accessory_type} {accessory_id} to {state}", True
                    )

                    try:
                        from gpiozero import LED, OutputDevice, Buzzer

                        # Map accessory IDs to actual GPIO pins
                        pin_mapping = {
                            "led_1": 23,
                            "led_2": 24,
                            "relay_1": 25,
                            "buzzer_1": 18,
                        }

                        if accessory_id in pin_mapping:
                            pin = pin_mapping[accessory_id]

                            # Create appropriate device based on accessory type
                            if accessory_type == "led":
                                device = LED(pin)
                            elif accessory_type == "relay":
                                device = OutputDevice(pin)
                            elif accessory_type == "buzzer":
                                device = Buzzer(pin)
                            else:
                                result = f"Unknown accessory type: {accessory_type}"
                                self.handler.send_message(
                                    "command_result",
                                    {"mac_address": self.mac_address, "result": result},
                                )
                                return

                            # Control the device
                            if state == "on":
                                device.on()
                            else:
                                device.off()

                            result = f"{accessory_type.capitalize()} {accessory_id} set to {state}"
                        else:
                            result = f"Unknown accessory ID: {accessory_id}"

                    except (ImportError, RuntimeError) as e:
                        result = f"Simulated: {accessory_type.capitalize()} {accessory_id} set to {state}"
                        self.debug_log(f"GPIO simulation mode due to: {str(e)}")

                    self.handler.send_message(
                        "command_result",
                        {"mac_address": self.mac_address, "result": result},
                    )
                    return
                except Exception as e:
                    self.debug_log(f"Error processing accessory control: {str(e)}")
                    self.handler.send_message(
                        "command_result",
                        {
                            "mac_address": self.mac_address,
                            "result": f"Error controlling accessory: {str(e)}",
                        },
                    )
                    return
            elif command.startswith("display_text:"):
                try:
                    data = json.loads(command[len("display_text:") :])  # ignore header

                    text = data.get("text", "")
                    options = {
                        "font": data.get("font", "9x18.bdf"),
                        "rows": data.get("rows", 64),
                        "cols": data.get("cols", 64),
                        "speed": data.get("speed", 0),
                        "y_pos": data.get("y_pos", 22),
                        "text_color": data.get("text_color", "255,0,255"),
                        "bg_color": data.get("bg_color", "0,50,0"),
                    }

                    success, result = self.matrix_controller.display_text(text, options)

                    self.handler.send_message(
                        "command_result",
                        {"mac_address": self.mac_address, "result": result},
                    )
                    return
                except json.JSONDecodeError as e:
                    self.debug_log(f"Error decoding display_text JSON: {str(e)}")
                    self.handler.send_message(
                        "command_result",
                        {
                            "mac_address": self.mac_address,
                            "result": f"Error: Invalid display_text format: {str(e)}",
                        },
                    )
                    return

            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=self.COMMAND_TIME_OUT,
            )

            output = result.stdout if result.returncode == 0 else result.stderr
            formatted_output = output.strip()

            self.handler.send_message(
                "command_result",
                {"mac_address": self.mac_address, "result": formatted_output},
            )
        except Exception as e:
            self.debug_log(f"Error executing command: {str(e)}")
            self.handler.send_message(
                "command_result",
                {"mac_address": self.mac_address, "result": f"Error: {str(e)}"},
            )


class WebSocketHandler:
    def __init__(
        self,
        url,
        mac_address,
        debug_callback,
        on_connected=None,
        on_disconnected=None,
        on_joined=None,
        on_command=None,
    ):
        """
        WebSocket handler that manages Phoenix protocol communication

        Args:
            url: WebSocket server URL
            mac_address: Device identifier
            debug_callback: Function to call for debug logs
            on_connected: Callback
            on_disconnected: Callback
            on_joined: Callback
            on_command: Callback
        """
        self.url = url
        self.mac_address = mac_address
        self.debug_log = debug_callback
        self.on_connected = on_connected
        self.on_disconnected = on_disconnected
        self.on_joined = on_joined
        self.on_command = on_command

        # WebSocket state
        self.ws = None
        self.connected = False
        self.joined = False
        self.connection_id = 0
        self.ref = 0
        self.last_heartbeat = 0

    def get_ref(self):
        """Get unique reference number for messages"""
        self.ref += 1
        return self.ref

    def connect(self, trace=False):
        """Establish WebSocket connection"""
        self.connection_id += 1
        websocket.enableTrace(trace)

        self.ws = websocket.WebSocketApp(
            self.url,
            on_message=self._on_message,
            on_error=self._on_error,
            on_close=self._on_close,
            on_open=self._on_open,
        )

        # Start WebSocket in background thread
        wst = threading.Thread(target=self.ws.run_forever)
        wst.daemon = True
        wst.start()

        # Start heartbeat thread
        heartbeat = threading.Thread(target=self._send_heartbeat)
        heartbeat.daemon = True
        heartbeat.start()

    def send_message(self, event, payload, ref=None):
        """Send a message to the WebSocket server"""
        if not self.ws or not self.connected:
            self.debug_log("Cannot send message: not connected")
            return

        if isinstance(payload, dict) and "mac_address" not in payload:
            payload["mac_address"] = self.mac_address

        message = {
            "topic": f"device:{self.mac_address}",
            "event": event,
            "payload": payload,
            "ref": ref if ref is not None else self.get_ref(),
        }

        self.debug_log(f"Sending message: {json.dumps(message)}")
        self.ws.send(json.dumps(message))

    def _send_heartbeat(self, interval=10):
        """Send periodic heartbeat messages to keep connection alive"""
        while True:
            if self.ws and self.connected and self.joined:
                try:
                    self.send_message("heartbeat", {})
                    self.last_heartbeat = time.time()
                    time.sleep(interval)
                except websocket.WebSocketConnectionClosedException:
                    self.connected = False
                    break
                except Exception as e:
                    self.debug_log(f"Heartbeat error: {str(e)}")
                    self.connected = False
                    break
            else:
                time.sleep(1)

    def _parse_phoenix_message(self, message):
        """Parse Phoenix protocol message"""
        try:
            msg = json.loads(message)
            res = {
                "type": msg.get("event"),
                "ref": msg.get("ref"),
                "topic": msg.get("topic", ""),
                "is_reply": msg.get("event") == "phx_reply",
                "status": None,
                "payload": msg.get("payload", {}),
                "command": None,
                "response": None,
                "raw": msg,
            }

            if res["is_reply"]:
                res["status"] = msg.get("payload", {}).get("status")
                res["response"] = msg.get("payload", {}).get("response", {})

            if res["type"] == "execute_command":
                res["command"] = msg.get("payload", {}).get("command")

            return res
        except Exception as e:
            self.debug_log(f"Error parsing Phoenix message: {str(e)}")
            return {"type": "error", "error": str(e), "raw": message}

    def _on_message(self, _ws, message):
        """Handle incoming WebSocket messages"""
        parsed_msg = self._parse_phoenix_message(message)
        current_connection = self.connection_id

        self.debug_log(f"Received message: {json.dumps(parsed_msg['raw'], indent=2)}")

        # Handle connection confirmation
        if (
            parsed_msg["is_reply"]
            and parsed_msg["ref"] == 1
            and not self.joined
            and parsed_msg["status"] == "ok"
        ):
            if current_connection == self.connection_id:
                self.debug_log(f"Device {self.mac_address} joined channel", True)
                self.joined = True
                if self.on_joined:
                    self.on_joined()

        # Handle command execution
        if parsed_msg["type"] == "execute_command" and parsed_msg["command"]:
            self.debug_log(f"Executing command {parsed_msg['command']}")
            if self.on_command:
                self.on_command(parsed_msg["command"])

        # Handle heartbeat confirmation
        if parsed_msg["type"] == "heartbeat" or (
            parsed_msg["is_reply"]
            and parsed_msg.get("response", {}).get("event") == "heartbeat"
        ):
            self.last_heartbeat = time.time()
            self.debug_log("Heartbeat received")

    def _on_error(self, _ws, error):
        """Handle WebSocket errors"""
        self.debug_log(f"WebSocket error: {error}", True)

    def _on_close(self, _ws, _close_status_code, _close_msg):
        """Handle WebSocket connection closure"""
        if self.connected:
            self.connected = False
            self.joined = False
            self.debug_log("WebSocket connection closed", True)
            if self.on_disconnected:
                self.on_disconnected()

    def _on_open(self, ws):
        """Handle WebSocket connection establishment"""
        self.connected = True
        self.debug_log("WebSocket connection opened", True)
        if self.on_connected:
            self.on_connected()

        # Join the Phoenix channel
        ws.send(
            json.dumps(
                {
                    "topic": f"device:{self.mac_address}",
                    "event": "phx_join",
                    "payload": {},
                    "ref": 1,
                }
            )
        )


def main():
    menu = Menu()
    config = menu.main_menu()

    client = Client(config)
    client.connect()

    try:
        while True:
            time.sleep(1)
            if not client.connected:
                client.debug_log("Reconnecting websocket.")
                client.joined = False
                client.connect()
    except KeyboardInterrupt:
        if client.connected:
            client.update_device_status("offline")
            client.send_system_log(f"{client.mac_address} shutdown")
            print("\nExiting program...")
            time.sleep(0.25)


if __name__ == "__main__":
    main()
