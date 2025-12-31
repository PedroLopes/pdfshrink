# pdfshrink

`pdfshrink` is a macOS and Linux-friendly Bash script for compressing PDF files with different quality options. It supports both interactive and flag-based workflows, optional file relocation, and safe overwrite handling.

(This was based in this [old script](https://raw.githubusercontent.com/PedroLopes/bashscripting/refs/heads/master/pdfshrink.sh), which was probbaly based on someone's answer on stackoverflow. This updated version includes some minor improvements, such as an install script and more options.)

---

## Features and usage overview

- Compress PDF files using Ghostscript (`gs`)
- Saves compressed file side by side with original by default
- Multiple compression quality options:
  - Highest-quality (prepress) ``--high`` (``-h``) or ``--prepress`` (**default if no arguments**)
  - Good (printer) ``--good`` (``-g``) or ``--printer`` 
  - Medium (ebook) ``--medium`` (``-m``) or ``--ebook``
  - Lowest (screen) ``--low`` (``-l``) or ``--screen``
- Interactive mode for selecting quality (`--interactive`)
- Optional overwrite of original file (`--override` / `-o`) with user confirmation
- Optional relocation of compressed file (`--relocate <dir>` / `-r <dir>`)

---

## Requirements

- Bash (compatible with macOS default Bash 3.2 or Linux Bash)
- Ghostscript (`gs`) installed and in `$PATH`
- Optional: Homebrew (macOS) or apt (Linux) for automated installation

---

## Automatic installation


```bash
git clone https://github.com/yourname/pdfshrink.git;
cd pdfshrink;
chmod +x install.sh;
./install.sh;
```

If you are on Mac and have ``brew`` or on linux and have ``apt``, the installer will automatically install ``gs`` for you, if its missing.

## Manual installation

```bash
git clone https://github.com/yourname/pdfshrink.git
cd pdfshrink
chmod +x pdfshrink.sh
```

Optionally, move it to a directory in your PATH:

```bash
mv pdfshrink.sh ~/.local/bin/pdfshrink
```

---

## Usage

```bash
pdfshrink.sh [options] <file.pdf>
```

### Options

| Option | Description |
|--------|------------|
| -i, --interactive | Select compression quality interactively |
| -h, --prepress, --high | Highest quality (prepress) [default] |
| -g, --printer, --good | Good quality (printer) |
| -m, --ebook, --medium | Medium quality (ebook) |
| -l, --low, --screen | Lowest quality (screen) |
| -o, --override | Replace the original file after compression (asks confirmation) |
| -r, --relocate <dir> | Move the compressed file to the specified directory |
| --help | Show help message |

### Examples

```bash
# Compress with default prepress quality
pdfshrink.sh file.pdf

# Interactive quality selection
pdfshrink.sh -i file.pdf

# Medium quality, override original file
pdfshrink.sh -m -o file.pdf

# Low quality and relocate compressed file
pdfshrink.sh -l -r ~/Desktop/Compressed file.pdf
```

---

## License

GNU GPL
