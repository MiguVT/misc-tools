# HaGeZi Updater

Downloads and merges HaGeZi DNS blocklists into a single file for Technitium DNS.

## What it does

Combines multiple HaGeZi blocklist sources (pro, spam, popups, hoster, dyndns) plus OISD Small list, removes duplicates, and outputs to `/var/technitium/www/hagezi-professional.txt`.

## Usage

```bash
chmod +x hagezi-updater.sh
./hagezi-updater.sh
```

## Automate with crontab

Add to crontab to run daily at 2 AM:

```bash
crontab -e
```

Add this line:

```bash
0 2 * * * /path/to/hagezi-updater.sh
```

## Customize

Edit the script and change:

```bash
HAGEZI_DIR="/path/to/your/dns/lists"
```

## Sources

- [HaGeZi DNS Blocklists](https://github.com/hagezi/dns-blocklists)
- [OISD](https://oisd.nl/)
