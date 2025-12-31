#!/usr/bin/env bash

# -----------------------------
# Defaults
# -----------------------------
compress="prepress"   # default quality
interactive=false
override=false
input_file=""

# -----------------------------
# Check if Ghostscript (gs) is installed
# -----------------------------
if ! command -v gs >/dev/null 2>&1; then
    echo "ERROR: gs (Ghostscript) command was not found."
    echo "You need to install it before running this script."
    echo "If you did not use the provided install.sh method, you can manually run:"
    echo "  brew install ghostscript (or other methods for your OS)"
    echo "Then retry this script."
    exit 1
fi


# -----------------------------
# Parse flags
# -----------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--interactive)
            interactive=true
            shift
            ;;
        -h|--prepress|--high)
            compress="prepress"
            shift
            ;;
        -g|--printer|--good)
            compress="printer"
            shift
            ;;
        -m|--ebook|--medium)
            compress="ebook"
            shift
            ;;
        -l|--low|--screen)
            compress="screen"
            shift
            ;;
        -o|--override)
            override=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            # First non-flag argument is the input file
            input_file="$1"
            shift
            ;;
    esac
done

# -----------------------------
# Validate input file
# -----------------------------
if [[ -z "$input_file" ]]; then
    echo "Usage: $0 [options] <file.pdf>"
    echo "Options:"
    echo "  -i, --interactive   Select quality interactively"
    echo "  -h, --prepress      Highest quality (default)"
    echo "  -g, --printer       Good quality (printer)"
    echo "  -m, --ebook         Medium quality (ebook)"
    echo "  -l, --low           Lowest quality (screen)"
    echo "  -o, --override      Replace original file"
    exit 1
fi

if [[ ! -f "$input_file" ]]; then
    echo "Error: File does not exist: $input_file"
    exit 1
fi

# -----------------------------
# Interactive selection
# -----------------------------
if $interactive; then
    PS3='Select compression: '
    options=("Highest-quality (prepress)" "Good (printer)" "Medium (ebook)" "Lowest (screen)" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Highest-quality (prepress)")
                compress="prepress"
                break;;
            "Good (printer)")
                compress="printer"
                break;;
            "Medium (ebook)")
                compress="ebook"
                break;;
            "Lowest (screen)")
                compress="screen"
                break;;
            "Quit")
                echo "Exiting."
                exit 0
                ;;
            *)
                echo "Invalid choice: $REPLY";;
        esac
    done
fi

# -----------------------------
# Compute filenames
# -----------------------------
base_name=$(basename "$input_file" ".pdf")
output_file="${base_name}_s.pdf"

if $override; then
    output_file="$input_file"
fi

# -----------------------------
# Compress PDF using Ghostscript
# -----------------------------
initial_size=$(du -m "$input_file" | cut -f1)

echo "Compressing $input_file → $output_file using '$compress' quality..."
gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/${compress} \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile="$output_file" \
   "$input_file"

final_size=$(du -m "$output_file" | cut -f1)
echo "Original size: ${initial_size} MB"
echo "Compressed size: ${final_size} MB"
echo "Size difference: $(($final_size - $initial_size)) MB"

