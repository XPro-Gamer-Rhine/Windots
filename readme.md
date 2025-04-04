<p align="center"> 
  <a href="https://scottmckendry.tech">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://scottmckendry.tech/img/logo/icon2transparent.png">
      <img src="https://scottmckendry.tech/img/logo/icon1transparent.png" height="100">
    </picture>
    <h1 align="center">Windots</h1>
  </a>
</p>

<p align="center">
  <a href="https://github.com/scottmckendry/Windots/commit">
    <img alt="LastCommit" src="https://img.shields.io/github/last-commit/scottmckendry/windots/main?style=for-the-badge&logo=github&color=%237dcfff">
  </a>
  <a href="https://github.com/scottmckendry/Windots/actions/workflows/sync.yml">
    <img alt="SyncStatus" src="https://img.shields.io/github/actions/workflow/status/scottmckendry/Windots/sync.yml?style=for-the-badge&logo=github&label=Sync%20to%20dots&color=%23bb9af7">
  </a>
  <a href="https://github.com/scottmckendry/Windots/blob/main/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/scottmckendry/Windots?style=for-the-badge&logo=github&color=%239ece6a">
  </a>
  <a href="https://github.com/scottmckendry/Windots/stars">
    <img alt="stars" src="https://img.shields.io/github/stars/scottmckendry/windots?style=for-the-badge&logo=github&color=%23f7768e">
  </a>
</p>

My personal Windows-friendly dotfiles. Supports automatic installation of dependencies and configuration of Windows Terminal, PowerShell Core, WezTerm, Starship, Oh-My-Posh, and more!

## 🎉 Features

- **One-Click Setup:** The enhanced Setup.ps1 script will automatically install and configure all necessary tools and modules.
- **Automated Dependency Installation:** Utilises [Winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) and [Chocolatey](https://chocolatey.org/) for streamlined installation of required dependencies.
- **Pokemon Terminal Decorations:** Includes [Pokemon-ColorScripts](https://github.com/pokeget/pokeget) for fun terminal decoration.
- **Centralized Configuration:** Brings together scattered Windows configuration files into one organized location for easy access and management.
- **PowerShell Modules & Tools:** Automatically installs and configures PSReadLine, Terminal-Icons, Oh-My-Posh, Starship, and more.
- **Improved Terminal Experience:** Configures Windows Terminal and WezTerm with optimized settings for productivity.

## ✅ Pre-requisites

- [PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3#install-powershell-using-winget-recommended)
- [Git](https://winget.run/pkg/Git/Git)
- [Sudo](https://learn.microsoft.com/en-us/windows/sudo/) (Optional) - With the **Inline** option to support automatic Windots & software updates.

## 🚀 Installation

> [!WARNING]\
> Under _**active development**_, expect changes. Existing configuration files will be overwritten. Please make a backup of any files you wish to keep before proceeding.

1. Clone the repository to the C drive: `git clone https://github.com/username/Windots.git C:\Windots`
2. Run `Setup.ps1` from an elevated PowerShell prompt: `cd C:\Windots`
3. ```pwsh -ExecutionPolicy Bypass -File .\Setup.ps1```

That's it! The script will automatically:

- Install all required dependencies via Winget and Chocolatey
- Install and configure PowerShell modules
- Set up Pokemon-ColorScripts
- Configure your PowerShell profile
- Create symbolic links for all configuration files
- Set up Windows Terminal, WezTerm, and other tools

## 🤝 Contributing

Pull requests and issues are welcome. If you have any questions or suggestions, please open an issue.

## 📸 Screenshots

![Terminal Preview](./previews/terminal.gif)
![PowerShell Preview](./previews/powershell.png)
![Windows Terminal Preview](./previews/windows-terminal.png)

---

<p align="center">
  <a href="https://scottmckendry.tech/tags/dotfiles/">
    <img alt="Static Badge" src="https://img.shields.io/badge/Blog_Posts-Go?style=for-the-badge&label=%F0%9F%92%ADRead&color=%237aa2f7">
  </a>
</p>
