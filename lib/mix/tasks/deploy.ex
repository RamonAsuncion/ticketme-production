defmodule Mix.Tasks.Deploy do
  use Mix.Task

  @shortdoc "SSH into the server, update code, run tests, and restart the Phoenix server"

  def run(_) do
    # ~<charliesid>/workspace/deploy.sh (public permissions on both script and folder with all subfiles)
    # chmod 777

    ssh_command = """
    ssh linuxremote3 << 'EOF'
      ~/workspace/deploy.sh
    EOF
    """

    {result, _exit_code} = System.cmd("bash", ["-c", ssh_command], stderr_to_stdout: true)
    IO.puts(result)
  end
end
