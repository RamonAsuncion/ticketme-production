# TicketMe

<p align="center"> <img src="assets/icon.png" width="120" alt="TicketMe Logo"/> </p> <p align="center"> <strong>A device monitoring and management system built with Phoenix LiveView</strong> </p>

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Demo](#demo)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Setup Instructions](#setup-instructions)
- [Usage Guide](#usage-guide)
  - [Create an Account](#create-an-account)
  - [Connecting a Client Device](#connecting-a-client-device)
  - [Adding a Device](#adding-a-device)
  - [Start the Client](#start-the-client)
  - [Monitoring and Controlling Devices](#monitoring-and-controlling-devices)
- [Development](#development)
  - [Project Structure](#project-structure)
  - [Running in Development Mode](#running-in-development-mode)
- [Testing](#testing)
- [License](#license)
- [Contributors](#contributors)

## Overview

TicketMe is a user-friendly, web-based platform that offers real-time monitoring and management of connected devices, especially Raspberry Pis. With this system, users can easily track device statuses, view detailed system logs, and send remote commands to devices through an intuitive and seamless web interface.

## Features

- User Authentication
- Device Management
- Real-time Communication
- Command Interface
- System Logs
- Data Visualization
- Responsive Design

## Demo

Watch our Beta release demonstration video to see TicketMe in action:

## Installation

### Prerequisites

- Elixir 1.14+
- Erlang 25+
- PostgreSQL 13+
- Node.js 16+
- Python 3.8+ (for client)

### Setup Instructions

1. Clone the repository

   ```sh
   git clone https://gitlab.bucknell.edu/af033/ticketme.git
   cd ticketme
   ```

2. Install Elixir dependencies

   ```sh
   mix setup
   ```

3. Configure the database

   ```sh
   mix ecto.migrate
   ```

4. Install Node.js dependencies

   ```sh
   cd assets/
   npm install
   cd ..
   ```

5. Start the Phoenix server

   ```sh
   mix phx.server
   ```

6. Access the application

Open your browser and navigate to [http://localhost:4000](http://localhost:4000).

## Usage Guide

### Create an Account

1. Navigate to [http://localhost:4000/users/register](http://localhost:4000/users/register)
2. Enter your name, email and create a password
3. Click the confirmation link sent to your email

### Connecting a Client Device

1. Navigate to the Python client directory.

   ```sh
   cd py
   python client.py
   ```

2. Configure your client

   - Set host: `localhost` (or your server address)
   - Set websocket path: `/socket/websocket`
   - Note the MAC address displayed by the client
   - Save the configuration

### Adding a Device

1. After logging in, you'll see your dashboard
2. Click the "+" button to add a new device
3. Enter a name for your device (e.g. "Device 1")
4. Enter the MAC address you noted from the client
5. Click "Add device"

### Start the Client

1. Return to your Python client
2. Run the client (or restart if already running)

   ```sh
   python client.py
   ```

3. Your device should now appear as "Active" in the dashboard.

### Monitoring and Controlling Devices

1. From your dashboard, you can access device details in two ways:

   - **Grid Mode**: Click directly on the device card
   - **Table View**: Click the link icon next to your device name

2. On the device page, you can:
   - View device status and system information
   - Monitor real-time logs
   - Send commands (type `help` to see available commands)
   - View performance charts and metrics
   - Configure alert thresholds and notification preferences

## Development

### Project Structure

- [lib](lib/) - Main application code
- [assets](assets/) - JavaScript, CSS, and static files
- [priv](priv/) - Database migrations and other private assets
- [py](py/) - Python client for connecting devices

### Running in Development Mode

```sh
mix phx.server
```

The server will start on port 4000 with live reloading enabled.

## Testing

Run the test suite with:

```sh
mix test
```

## License

TicketMe is released under the Apache 2.0 License. See the LICENSE file for details or read [here](https://www.apache.org/licenses/LICENSE-2.0).

## Contributors

- Ramon Asuncion
- Bhenzel Cadet
- Charlie Ehrbar
- Nolan Sauers
- Sarah Thomas
- Gordon Rose
