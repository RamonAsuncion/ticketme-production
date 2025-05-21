defmodule Ticketme.Email do
  import Swoosh.Email

  @doc """
  Builds a plain-text welcome email for a newly registered user.

  ## Parameters
    - `to_address` (string): The recipient's email address.

  ## Returns
    - A `%Swoosh.Email{}` struct ready to be sent using `Ticketme.Mailer.deliver/1`.

  ## Example

      Ticketme.Email.welcome_email("user@example.com")
      |> Ticketme.Mailer.deliver()
  """
  def welcome_email(to_address) do
    new()
    |> to(to_address)
    |> from({"Ticketme", "postmaster@sandboxf95566671b144e2094e48b754a71452b.mailgun.org"})
    |> subject("🎉 Welcome to Ticketme!")
    |> text_body("""
    Welcome to Ticketme — your smart IoT device management portal.

    We're excited to help you monitor and manage your connected devices with ease.

    Get started by logging into your dashboard and exploring the tools we've built for you.

    Happy monitoring!
    – The Ticketme Team
    """)
    |> html_body("""
    <div style="font-family: sans-serif; line-height: 1.6; color: #333;">
      <h2 style="color: #ff7f50;">🎉 Welcome to Ticketme!</h2>
      <p>We're excited to have you on board.</p>
      <p>
        <strong>Ticketme</strong> is your all-in-one platform for managing IoT devices with real-time insights, alerts, and controls.
      </p>
      <p>
        Log in to your dashboard to get started and explore your device network.
      </p>
      <hr style="border: none; border-top: 1px solid #eee;" />
      <p style="font-size: 0.9em; color: #888;">
        Need help? Contact our support team anytime.<br />
        Happy monitoring!<br />
        – The Ticketme Team
      </p>
    </div>
    """)
  end

  def device_alert(to_address, device, alert_message) do
    new()
    |> to(to_address)
    |> from({"Ticketme Alerts", "alerts@ticketme.io"})
    |> subject("⚠️ Alert: Device '#{device.device_name}' Exceeded ")
    |> text_body("""
    Alert from Ticketme IoT Dashboard

    Device Name: #{device.device_name}
    Device ID: #{device.device_id}
    MAC Address: #{device.mac_address}
    Device Type: #{device.device_type}
    Status: #{device.status}
    Last Active: #{device.last_active_at}

    ⚠️ Alert Message:
    #{alert_message}

    Please log in to your dashboard for more details.
    """)
    |> html_body("""
    <div style="font-family: sans-serif; color: #333;">
      <h2 style="color: #e53e3e;">⚠️ Alert: Threshold Exceeded</h2>
      <p><strong>Device:</strong> #{device.device_name} (#{device.device_id})</p>
      <ul>
        <li><strong>MAC Address:</strong> #{device.mac_address}</li>
        <li><strong>Type:</strong> #{device.device_type}</li>
        <li><strong>Status:</strong> #{device.status}</li>
      </ul>
      <p style="color: #b83232; font-weight: bold;">#{alert_message}</p>
      <p>Visit your <a href="https://http://localhost:4000//dashboard" style="color: #3182ce;">dashboard</a> to take action.</p>
      <hr />
      <p style="font-size: 0.9em; color: #888;">– Ticketme Alerts Team</p>
    </div>
    """)
  end

  def device_created_email(to_address, device) do
    new()
    |> to(to_address)
    |> from("postmaster@sandboxf95566671b144e2094e48b754a71452b.mailgun.org")
    |> subject("✅ New Device Added: #{device.device_name}")
    |> text_body("""
    Hello,

    A new device has been successfully added to your Ticketme dashboard.

    Device Name: #{device.device_name}
    Device ID: #{device.device_id}
    MAC Address: #{device.mac_address}
    Device Type: #{device.device_type}
    Status: #{device.status}

    You can now manage this device through your dashboard.

    – The Ticketme Team
    """)
    |> html_body("""
    <div style="font-family: sans-serif; line-height: 1.6; color: #333;">
      <h2 style="color: #38a169;">✅ New Device Added</h2>
      <p><strong>#{device.device_name}</strong> has been added to your account.</p>
      <ul>
        <li><strong>Device ID:</strong> #{device.device_id}</li>
        <li><strong>MAC Address:</strong> #{device.mac_address}</li>
        <li><strong>Type:</strong> #{device.device_type}</li>
        <li><strong>Status:</strong> #{device.status}</li>
      </ul>
      <p>
        Manage this device in your <a href="http://localhost:4000/dashboard" style="color: #3182ce;">Ticketme Dashboard</a>.
      </p>
      <hr style="border: none; border-top: 1px solid #eee;" />
      <p style="font-size: 0.9em; color: #888;">– The Ticketme Team</p>
    </div>
    """)
  end
end
