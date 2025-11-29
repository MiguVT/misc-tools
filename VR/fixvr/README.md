# Fix PCVR Connection Issues on Linux

Tired of the old routine on Linux where you have to open SteamVR and click "Restart Headset," or physically unplug and replug the cable just to get the DRM to work? This script automates the headset restart process using `lighthouse_console`, so you don't have to depend on the full SteamVR interface.

### Usage

**Offline Method**
This method works without an internet connection. Simply download the script and execute it.
```bash
./fixvr.sh
```

**Online Method**
This is the simplest approach, just one command and you're done. However, be aware of the security risks of piping scripts from the internet. If my account were ever compromised, malicious code could potentially be injected. The risk is low since you should not use `sudo` with this script, but it's important to be cautious.
```bash
curl -s https://raw.githubusercontent.com/MiguVT/misc-tools/main/VR/fixvr/fixvr.sh | bash
```

### How It Works
It's a very simple but helpful script. Just check the source code and you'll understand everything it does.
