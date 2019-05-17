#
# Not used, just some prototype code.
#

sudo "VAGRANT_HOME=${VAGRANT_HOME}" macinbox --box-format vmware_desktop --vmware /Applications/VMware\ Fusion\ 10.app --no-fullscreen --nohidpi

vagrant init macinbox
vagrant up

vagrant ssh

# Mojave
xcode-select --install
sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /

#CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install 3.5.2 

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install pyenv
PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install 3.7.2
pyenv global 3.7.2
rehash
