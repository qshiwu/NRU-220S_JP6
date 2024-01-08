# NRU-220S_JP6

Additional files for JP6.0 porting

# Installation Startup Scripts and Related Tools
sudo ./install.sh

# Memo for Furture Me to Build Everything from Scratch

## libgpiod
git clone git://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
cd libgpiod

### Dependency Packages
sudo apt-get install automake
sudo apt-get install autoconf-archive

### 
sudo ./autogen.sh
sudo ./autogen.sh --enable-tools=yes
sudo make
sudo make install


## mdio

### Ref: https://stackoverflow.com/questions/32594877/libmnl-issue-while-installing-libnetfilter-queue-in-linux

### install libmnl
wget https://www.netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2
tar -xvf libmnl-1.0.5.tar.bz2
cd libmnl-1.0.5/
./configure
make
sudo make install
cd ..

### Deal with certification for further installation
cd /lib/modules/$(uname -r)/build/certs
sudo tee x509.genkey > /dev/null << 'EOF'
[ req ]
default_bits = 4096
distinguished_name = req_distinguished_name
prompt = no
string_mask = utf8only
x509_extensions = myexts
[ req_distinguished_name ]
CN = Modules
[ myexts ]
basicConstraints=critical,CA:FALSE
keyUsage=digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
EOF

sudo openssl req -new -nodes -utf8 -sha512 -days 36500 -batch -x509 -config x509.genkey -outform DER -out signing_key.x509 -keyout signing_key.pem
 
sudo apt-get install mokutil
sudo mokutil --disable-validation
admin.123.123
sudo reboot 

### finally get mdio-tools source code
git clone https://github.com/wkz/mdio-tools
cd mdio-tools
sudo apt-get install openssl automake autoconf libtool mokutil
sudo ./autogen.sh

###  Use this command to install
sudo ./configure --prefix=/usr && make all && sudo make install
cd kernel 
make



