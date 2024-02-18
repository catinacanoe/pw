vim:ft=markdown

[https://github.com/catinacanoe/pw](https://github.com/catinacanoe/pw)
`pw`, a wrapper to turn `pass` into a more convenient password manager

# Notes
  Currently only works with `hyprland`. If anyone is interested, send me a message (`catinacanoe.mail@gmail.com`) and I can work on changing that.

# Installation

  Clone this repository: `git clone 'https://github.com/catinacanoe/pw.git'`.
  All of the functionality is stored inside `main.sh`, so all you need to do is set an alias (or anything equivalent) like this: `alias pw="/path/to/repo/pw/main.sh"` in your `.bashrc` or `.zshrc`.
  You must also set an environment variable `$DMENU_PROGRAM` to the name of the menu program you would like `pw` to use. This program should read standard input line by line and print the chosen item to standard output. Something like `dmenu` or `tofi`.

## NixOS

   I personally use nixos, and there is a really nice way to install stuff like this. With `home.nix` use:
   `home.packages = [ (pkgs.writeShellScriptBin "pw" "/path/to/repo/pw/main.sh $@") ];`

   And with `configuration.nix`, use:
   `environment.systemPackages = [ (pkgs.writeShellScriptBin "pw" "/path/to/repo/pw/main.sh $@") ];`
   
   To set the `$DMENU_PROGRAM` environment variable, you can put this into your `home.nix`:
   `home.sessionVariables.DMENU_PROGRAM = "tofi";` where `tofi` is the menu program you want to use.

# Usage

  There aren't many arguments, most of the important stuff happens in the `.map` file, described later.

## help

   `--help`, `-h`

   just prints out this readme

## main usage

   (no arguments)

   uses the password `.map` mentioned previously to determine what to do and types the corresponding keysequence, asking for user input only when necessary.

## interactive

   `--interactive`, `-i`

   uses the password `.map` to put more relevant options at the top of menus but does not assume anything: asks for user input at every decision.

# Map File

  This file just maps from the current window's title and class to what `pw` should type. This file must be located at `$PASSWORD_STORE_DIR/.map`

## General Info

   - empty lines are ignored
   - lines where the first non-whitespace character is `#` are ignored
   - lines should be in the format: `<class> /// <title> /// <pass-folder> /// <keysequence>`
   - the class pattern can also be `browser`, `terminal`, or `editor`. These will match when the current window's class is exactly equal to the contents of `$BROWSER`, `$TERMINAL`, or `$EDITOR`, respectively
   - the file is read top to bottom, so put more specific match patterns earlier, and more general ones towards the end

## Line Format

   As mentioned previously, the lines should be formatted like this: `<class> /// <title> /// <pass-folder> /// <keysequence>`

   - `<class>` can be a regex, or one of `browser`, `terminal`, or `editor`. 
   - `<title>` must be a regex
   - `<pass-folder>` is the subfolder of `$PASSWORD_STORE_DIR` in which the credentials for this specific class / title combination are stored.
   - `<keysequence>` is a string like `uTpE` that describes exactly what `.gpg` files from the specified subfolder should be decrypted and typed.

## Class and Title

   When `pw` is called, it just goes through the `.map` file, trying to find a line where both the class and title string match the current window's class and title. Vanilla grep is used for this: `[ -n "$(echo "$window_class" | grep "$class_pattern")" ]`. When a match is found, that line's pass folder and key sequence are used to decide what to do further. If no match is found, the user will have to select the pass folder and pass entry from within that folder to type.

## Pass Folder

   This just specifies what subfolder of `$PASSWORD_STORE_DIR` to use when selecting the pass entry to type. You can have a specific subfolder to use, or you can also just put a partial string. For example, if I have two github accounts I can have two subfolders under `$PASSWORD_STORE_DIR`: `github-bob/` and `github-jane/`. If I set the `<pass-folder>` to just `github` on a certain line, I will be prompted to choose between the two accounts when that line matches. Then, the folder I select will be used.

## Key Sequence

   As mentioned before, the key sequence describes exactly what entries in the pasword store should be typed out. The sequence is read character by character from the start to the end. This how each character is handled.

   If the character is a lowercase letter, `pw` will just find all of the pass entries under the specified subfolder that start with that letter. If there is just one and we are not in interactive mode, `pw` will just run `pass` on that entry to decrypt it and type out the decrypted text into the focused window. Otherwise, `pw` will let the user select from all of the matching pass entries.

   If the character is an upercase letter, this signifies a special key to be typed:
   - `T` means to press the `Tab` key
   - `E` means to press the `Return`/`Enter` key
   - `R` means to press the `Return`/`Enter` key
   - ` ` means to press the `space` key

   If the character is a symbol, this means to type the pass entry that matches a specific string.
   - `$` means the hostname
   - `~` means the username

   If the character is a `.`, the user just selects which pass entry to use.

   If there is no key sequence defined: `abc /// abc /// abc`, `pw` just lets the user select what entry to use (same as if the key sequence was just `.`)

## Example

   If the contents of `$PASSWORD_STORE_DIR/.map` is as follows:
   ```
   # class /// title /// pass-folder /// keysequence
   fi.*r /// Sign in to GitHub /// github /// pTuE
   browser /// Github /// github
   ```

   The resulting behavior will be as follows:

   - When `pw` is called and the current active window class contains `fi`, followed by `r` and the window title contains `Sign in to GitHub`, `pw` will type the output of `pass github/p{}` (where `p{}` represents a pass entry under `github/` that starts with `p`) into the active window, then press the `Tab` key, then type `pass github/u{}` into the window, and finally press `Enter`.
   - If the above case did not match but the current window's class is the same as `$BROWSER` and the window title contains `Github`, a menu will pop up, containing the output of `pass ls github` because `github` is the pass-folder field. If for example the user chooses `email` from this list, then the output of `pass github/email` will be typed into the active window.
