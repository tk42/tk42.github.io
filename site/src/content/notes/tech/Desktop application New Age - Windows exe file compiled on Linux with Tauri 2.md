---
title: Desktop application New Age - Windows exe file compiled on Linux with Tauri 2
date: 2024-11-07
tags: 004/2,004/6,004/7,004/8,004/9
publish: true
feed: show
---
### Introduction
In desktop application development on Windows, C# (.NET Framework) is a solid and reliable way to build. On the other hand, Electron has become increasingly popular for desktop applications due to its ability to leverage web technologies (HTML, CSS, JavaScript) and create cross-platform applications with a single codebase. However, Electron applications typically consume more system resources and have a larger footprint compared to native C# applications.

Lately, Tauri has become more popular and high-flying for building not only desktop applications but also mobile apps due to its significantly smaller bundle size and better performance compared to Electron. Tauri uses the native operating system's webview instead of bundling Chromium, resulting in much smaller executables. It also leverages Rust for the backend, providing better security and performance while allowing developers to use familiar web technologies (React, Vue, Svelte, etc.) for the frontend.
Some key advantages driving Tauri's adoption include:

- Much smaller application size (often 600KB-3MB vs Electron's 120MB+)
- Lower memory usage
- Native system integrations via Rust
- Strong security model
- Support for multiple frontend frameworks
- Mobile support in development (currently in alpha)

### TL;DR (How to setup)

[GitHub - tk42/tauri-tutorial](https://github.com/tk42/tauri-tutorial/)

This repo (tk42/tauri-tutorial) is a very handy and portable due to its well-organized structure and comprehensive examples that demonstrate key Tauri functionalities. Let's analyze what makes it particularly useful:

```
tauri-tutorial/
├── tauri-app/         # Tutorial app
│   ├── src-tauri/     # Rust backend
│   ├── src/           # Frontend (React/TypeScript)
│   ├── public/        # Static assets
│   ├── build.sh       # Cross compile commands for exe file
│   ├── package.json
│   ├── tsconfig.json
│   ├── index.html
│   ├── tsconfig.node.json
│   ├── vite.config.ts
│   ├── yarn.lock
│   └── ...
└── .devcontainer/     # .devcontainer for VSCode
```

Key Features:
- TypeScript + React setup with Tauri
- **Dockerfile included**
- **Remote dev container with VSCode**

So even if you are using Linux, you can keep your local environment clean as the development environment is set up with these windows packages on the Docker container. Thus, now you can develop exe file for windows application on your Linux or whatever you want as long as the Docker works properly. This is amazing.

Check out Tauri project right now! This project has a lot of possibilities for most GUI developers.