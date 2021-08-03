# How to install SAIgimp
## On Linux with flatpak version of GIMP 2.10

Extract all folders

- `.icons`
- `.var`
- `.local`

to your /home folder.

## On Linux with GIMP installed through package manager 

Extract all hidden folders

- `.icons`
- `.var`
- `.local`

to your /home folder and then move the subfolder

- `.var/app/org.gimp.GIMP/config/GIMP/2.10`

to `~/.config/gimp/2.10`.

Afterwards you can delete `.var/app/org.gimp.GIMP` respectively `.var`.

## On Windows

In this first release, SAIgimp has not been tested on Windows. It may work but without guarantees.
