# Development History

### How slowfetch came to be
My journey with what would become slowfetch began around December 2023, as I started delving into the possibilities of `fastfetch`. The initial concept was ambitious and thematic: an over-the-top "mega Arch btw" fetch. I envisioned a theme of worship, complete with Bible verses, a church background in the terminal, and a glowing Arch logo.

As I added more modules, the project's focus shifted from aesthetics to pure functionality. I wanted to flex what was possible, creating modules that were significantly more informative than their standard counterparts. A prime example is the disk module, which evolved into a mini-"gparted," capable of even identifying USB flash drives.

The main development hurdle was my workflow. Not realizing I could simply call an external `.sh` script from the config, I forced AI to generate complex logic as a single, heavily-escaped line to be embedded directly into the JSON. This was a nightmare, as the complex escaping and convoluted logic were incredibly difficult to handle correctly.

The breakthrough came in a single, intense 7-hour session. Using Gemini and Cursor AI, I finally refactored the entire project. The monolithic configuration was broken down into a clean, modular collection of individual scripts. During this sprint, I tested everything, wrote a few new modules, and iteratively built the installer which also serves as the interactive configurator.

### February 2025 — TUI Rethink and Bash Editors
In February 2025, the TUI was radically reconsidered. Instead of relying on external dialog utilities or manual editing, the configurator moved toward a fully integrated experience. 

Key changes in this update:
- **Integrated Bash Editors**: Custom interactive editors were built directly in Bash using `tput` and raw input handling. While they might not be "perfect" in terms of pure code elegance, they are highly practical and provide a comfortable, responsive UX for reordering and adding modules.
- **Alternative Screen Buffer**: The manager now utilizes the terminal's alternate screen buffer (`smcup`/`rmcup`). This is a major improvement: the configurator no longer clutters your primary terminal scrollback. When you exit, your terminal state is perfectly restored to exactly how it was before launching.
- **Structural Overhaul**: The project structure was redesigned to better align with TUI requirements. Configuration management (`config_manager.sh`) and module settings (`configurators.sh`) were separated, allowing for more dynamic interaction between the interface and the script metadata.
- **Refined UX**: The shift to native Bash logic makes the tool more portable and ensures the interface remains lightweight while offering "grab-and-move" module management.