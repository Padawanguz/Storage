# Defined in - @ line 1
function import-key --wraps='gpg --keyserver keyserver.ubuntu.com --recv-keys' --description 'alias import-key=gpg --keyserver keyserver.ubuntu.com --recv-keys'
  gpg --keyserver keyserver.ubuntu.com --recv-keys $argv;
end
