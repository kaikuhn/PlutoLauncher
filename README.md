
# PlutoLauncher

**PlutoLauncher** is a tool to launch [Pluto.jl](https://github.com/fonsp/Pluto.jl) in a predefined environment using your browser's app mode or an Electron window. It allows you to create or open a Pluto script without using the terminal. Additionally, existing scripts or folders can be opened directly via the file manager's context menu.

Since **PlutoLauncher** just consists of a short launching-script, calling Pluto from the **Pluto.jl** Package, it is easy to maintain.

---

## Browser Requirements

For PlutoLauncher it is recommended to have a **Chromium-based browser** installed, in order to run Pluto in the Browsers app mode. The following browsers are officially supported:

- **Chromium** (recommended)
- **Google Chrome**
- **Brave**
- **Microsoft Edge**

If you use a different Chromium-based browser, you can manually add support for it by modifying the script.
**Note:** Firefox is **not supported**, as Pluto's PWA (Progressive Web App) functionality is not available in Firefox.

In case no chromium based browser is installed, the script will try to open an **Electron.jl** window application.

---

## Julia Dependency

PlutoLauncher requires **[Julia](https://julialang.org/)** to be installed on your system, as Pluto.jl is built on Julia.

- If Julia is **not installed**, the installation script will automatically install it for you.
- If Julia is already installed, PlutoLauncher will use the existing installation.

---

## Installation

### Linux

To install PlutoLauncher on **Linux**, run the following command in your terminal:

```
curl -fsSL https://raw.githubusercontent.com/kaikuhn/PlutoLauncher/main/linux_install.sh | bash
```

## Uninstallation

### Linux

To uninstall PlutoLauncher, use:

```
curl -fsSL https://raw.githubusercontent.com/kaikuhn/PlutoLauncher/main/linux_uninstall.sh | bash
```
---

## Windows Support

Windows installation scripts are currently in development. Stay tuned for updates!

---

## Updating Pluto

To update Pluto.jl to the latest version, open a terminal and run:

```
Pluto --update
```

---

## First-Time Usage

When running PlutoLauncher for the first time, it may take a few minutes to start. This is because Pluto.jl is being precompiled for your system. Subsequent launches will be faster.

## Notes

- PlutoLauncher is designed to work offline after the initial setup.
- For issues or feature requests, please open an issue on the GitHub repository.

---

## Contribute

Contributions are welcome! Feel free to submit a pull request.

- Install script and Execution script for Windows and MacOS
- Extend the browser list in the `get_browser()` function
- Test the Electron Application
- Open Issues, when you experience errors related to the script
