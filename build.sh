#!/usr/bin/env bash

HERE="$(dirname "$(readlink -f "${0}")")"

function downloadGIMP () {
  echo "\nDownloading GIMP...\n"

  export VERSION=$(wget -q "https://github.com/PhotoMP/gimp-appimage/releases" -O - \
                      |  grep -e '<a href.*GIMP_AppImage-git.*.AppImage"'                \
                      |  cut -d '"' -f 2                                                 \
                      |  cut -d / -f 7                                                   \
                      |  sort -Vr                                                        \
                      |  grep withplugins                                                \
                      |  grep -v 2.99                                                    \
                      |  head -n 1                                                       \
                      |  cut -d "-" -f 3-4)

  RELEASE_PATH="aferrero2707/gimp-appimage/releases/download/continuous"

  wget -c https://github.com/$RELEASE_PATH/GIMP_AppImage-git-$VERSION-x86_64.AppImage -O GIMP.AppImage

  chmod +x GIMP.AppImage
  ./GIMP.AppImage --appimage-extract > /dev/null
}

function downloadAppImageTool () {
  echo "\nDownloading AppImageTool...\n"

  wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
  chmod +x ./appimagetool-x86_64.AppImage
}

function replaceFiles() {
  echo -e "\nCopying new brushes...\n"
  mv ".var/app/org.gimp.GIMP/config/GIMP/2.10/brushes/"* "squashfs-root/usr/share/gimp/2.0/brushes"

  echo -e "\nReplacing splash screen...\n"
  mv ".var/app/org.gimp.GIMP/config/GIMP/2.10/splashes/saigimp.png" "squashfs-root/usr/share/gimp/2.0/images/gimp-splash.png"

  echo -e "\nRemoving unneeded files...\n"
  rm -rfv ".var/app/org.gimp.GIMP/config/GIMP/2.10/brushes"
  rm -rfv ".var/app/org.gimp.GIMP/config/GIMP/2.10/splashes"
  rm -rfv ".var/app/org.gimp.GIMP/config/GIMP/2.10/tags.xml"

  mv ".var/app/org.gimp.GIMP/config/GIMP/2.10" squashfs-root/PATCH
}

function patchIcon() {
  echo -e "\nReplacing AppIcon...\n"
  mv ../.local/share/applications/org.gimp.GIMP.desktop saigimp.desktop
  rm gimp.desktop
  mv ../.local/share/icons/hicolor/saigimp.png saigimp.png
  ln -fs saigimp.png .DirIcon
  rm gimp.png
}

function patchStartup() {
  echo -e "\nCreating PhotoGIMP startup script...\n"

  mkdir -p startup_scripts/
  chmod +x ../startup_saigimp.sh
  cp ../startup_saigimp.sh startup_scripts/saigimp.sh
}

function patchWindowIcon() {

  echo -e "\nReplacing window icon...\n"

  find usr/share/gimp/2.0/icons/ -name "gimp-wilber.svg" \
                                 -exec echo rm -v $1 {} \;  \
                                 -exec cp -v saigimp.png $1 {} \;
}

function packAppImage() {
  echo -e "\nPackaging AppImage...\n"
  mv squashfs-root SAIgimp.AppDir
  ARCH=x86_64 ./appimagetool-x86_64.AppImage SAIgimp.AppDir
  cp SAIgimp-*-x86_64.AppImage SAIgimp-x86_64.AppImage
}


tar -xf "SAIgimp for Linux.tar.xz"  > /dev/null
downloadGIMP
downloadAppImageTool
replaceFiles
chmod -R a+rx squashfs-root
cd "squashfs-root/"
patchIcon
patchStartup
patchWindowIcon


sed -i '/^Version=/d' saigimp.desktop

cd "${HERE}"
packAppImage

apt install zsync

zsyncmake SAIgimp-x86_64.AppImage



