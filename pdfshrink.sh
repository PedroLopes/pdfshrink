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

show_help() {
    cat << EOF
Usage: $(basename "$0") [options] <file.pdf>

Options:
  -i, --interactive       Select compression quality interactively
  -h, --prepress, --high  Highest quality (prepress) [default]
  -g, --printer, --good   Good quality (printer)
  -m, --ebook, --medium   Medium quality (ebook)
  -l, --low, --screen     Lowest quality (screen)
  -o, --override          Replace the original file instead of creating a copy (mutually exclusive with --relocate)
  -r, --relocate <dir>    Move the compressed file to a specified directory (otherwise file is saved in same directory as the target file)
  --help                  Show this help message and exit

Examples:
  $(basename "$0") file.pdf
  $(basename "$0") --ebook file.pdf
  $(basename "$0") -i file.pdf
  $(basename "$0") -g -o file.pdf
EOF
    exit 0
}

# -----------------------------
# Check for --help
# -----------------------------
for arg in "$@"; do
    if [[ "$arg" == "--help" ]]; then
        show_help
    fi
done


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
	    -r|--relocate)
	    if [[ -n "$2" && ! "$2" =~ ^- ]]; then
		relocate_dir="$2"
		shift 2
	    else
		echo "Error: --relocate requires a directory argument"
		exit 1
	    fi
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

# let's also validate if the relocated dir exists
if [[ -n "$relocate_dir" ]]; then
    if [[ ! -d "$relocate_dir" ]]; then
        echo "Error: Relocation directory does not exist: $relocate_dir"
        exit 1
    fi
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
dir_name=$(dirname "$input_file") # get input file directory
output_file="${dir_name}/${base_name}_s.pdf" # by default saves it side by side

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

# If relocate_dir is set, move the compressed file there
if [[ -n "$relocate_dir" ]]; then
    echo "Relocating $output_file to $relocate_dir"
    mv "$output_file" "$relocate_dir/"
    output_file="$relocate_dir/$output_file"
fi

# Safer to do the override check at the end
if $override; then
    if $relocate; then
	    echo -e "  (Warning: both --override and --relocate were provided.\n  However, this will not override the file as these options are mutually exclusive.\n  As such, --relocate takes priority to prevent errors and the file was relocated.)"

    else
	    echo -n "Do you want to overwrite the original file ($input_file) with the compressed version? [y/N]: "
	    read answer
	    case "$answer" in
		[Yy]* )
		    mv -f "$output_file" "$input_file"
		    echo "Original file overwritten."
		    ;;
		* )
		    echo "Original file left unchanged. Compressed file saved as $output_file"
		    ;;
	    esac
   fi
fi


