#!/bin/bash

for i in libtool wget curl python automake autoconf bnfc zlib1g-dev libgmp-dev libtinfo-dev binutils-dev libunwind-dev; do

  #T=`which "$i" 2>/dev/null`
  PKG_OK=`dpkg-query -s "$i" |grep "install ok installed"`
  

  if [ "$PKG_OK" == "" ]; then

    echo "[-] Error: '$i' not found"
    sudo apt-get install $i -y || exit 1
    echo "[+] installed '$i' "

  fi

done

cd ./src/Test/QuickFuzz/Gen/Bnfc/ || exit 1
bnfc --haskell -p Test.QuickFuzz.Gen.Bnfc Grammar.cf || exit 1
sudo mv ./Test/QuickFuzz/Gen/Bnfc/* . || exit 1
sudo rm -rf Test || exit 1 
cd ../../../../../

_PKG_DIR="packages"

mkdir -p $_PKG_DIR
cd $_PKG_DIR

TARGET="radamsa"

if [ -d "$TARGET" ];then
    echo "[!] $TARGET already exists"
else

    echo "[!] downloading $TARGET ..."
    git clone https://github.com/CIFASIS/radamsa

fi

echo "[*] installing $TARGET..."
cd $TARGET
git pull
make
mv owl-0.1.9 owl-lisp-0.1.9 && cd owl-lisp-0.1.9 && sudo make bin/vm 
sudo make install DESTDIR=$HOME/.local PREFIX="" || exit 1
cd ..
echo "[+] installed $TARGET!"

TARGET="zzuf"

if [ -d "$TARGET" ];then
    echo "[!] $TARGET already exists"
else

    echo "[!] downloading $TARGET ..."
    git clone https://github.com/CIFASIS/zzuf

fi

echo "[*] installing $TARGET..."
cd $TARGET
./bootstrap
./configure --prefix=$HOME/.local
sudo make install || exit 1
cd ..
echo "[+] installed zzuf!"

TARGET="honggfuzz"

if [ -d "$TARGET" ];then
    echo "[!] $TARGET already exists"
else

    echo "[!] downloading $TARGET ..."
    git clone https://github.com/CIFASIS/honggfuzz

fi

echo "[*] installing $TARGET..."
cd $TARGET
pwd
patch -p0 <../../patches/files.diff || exit 1
patch -p0 <../../patches/bfd.diff || exit 1
patch -p0 <../../patches/Makefile.diff || exit 1
sudo make || exit 1
cp ./honggfuzz $HOME/.local/bin
echo "[+] installed honggfuzz!"

