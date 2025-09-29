# Node/React Project Security Scanner

This script scans your Node.js or React project for known compromised npm packages from the **Shai-Hulud attack**.  
It checks all `package.json` files inside your `node_modules` (including nested ones) and produces both console output and a CSV report.

---

## Prerequisites

- Bash shell (Linux, macOS, or WSL2)
- A Node.js or React project with a `node_modules` folder
- `compromised.txt` containing the known compromised package names (I'll update if new ones are added)
- The script (`node_sh_check.sh`) and `compromised.txt` in the same folder

---

## Installation / Setup

Clone or copy the repo to your home directory or a folder of your choice:

```bash
git clone https://github.com/yuri-gagarin/sh-node-project-check.git ~/sh_node_project_check
cd ~/sh_node_project_check
# make it executable
chmod +x node_sh_check.sh
# run the program and point it to your project directory
./node_sh_check.sh /path/to/your/project
```

## Example Output

```bash
⚠️  Total known compromised packages in list: 526
📦 Scanning project at: /home/user/my-react-app
------------------------------------------------------------
Working on react@18.2.0... OK
Working on pm2-gelf-json@1.0.4... ⚠️ WARNING
Working on lodash@4.17.21... OK
------------------------------------------------------------
Scan complete.
Total packages scanned: 52
Compromised packages found: 1
📄 Report saved to: compromised_report.csv
```

## What to Do if a Package Is Found to Be Compromised
If the scan identifies any compromised packages:

1. **Do not panic** — the script only detects potential risks.
2. Check if the compromised dependency comes from your `package.json` or is a transitive dependency.
3. Run:

```bash
npm ls <package-name>
npm uninstall <package-name>
npm install safe-alternative@latest
npm cache clean --force
```

(Or similar [yarn] or [pnpm] commands if you use those)

Rotate any exposed credentials — GitHub tokens, API keys, SSH keys, or .env secrets if there is a chance they were accessible.