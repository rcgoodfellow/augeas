#! /bin/sh

# Test that we report an error when writing to nonexistant dirs
# but that we do create new files correctly

save_hosts() {
(augtool -r $ROOT | grep ^/augeas) <<EOF
set /files/etc/hosts/1/ipaddr 127.0.0.1
set /files/etc/hosts/1/canonical localhost
save
print /augeas/files/etc/hosts/error
EOF
}

expected_errors() {
cat <<EOF
/augeas/files/etc/hosts/error = "open_augnew"
/augeas/files/etc/hosts/error/message = "No such file or directory"
EOF
}

ROOT=$abs_top_builddir/build/test-save-empty
HOSTS=$ROOT/etc/hosts

rm -rf $ROOT
mkdir -p $ROOT
ACTUAL=$(save_hosts)
EXPECTED=$(expected_errors)

if [ "$ACTUAL" != "$EXPECTED" ]
then
    echo "No error on missing /etc directory"
    exit 1
fi

mkdir -p $ROOT/etc
ACTUAL=$(save_hosts)
if [ -n "$ACTUAL" ] ; then
    echo "Error creating file:"
    echo $ACTUAL
    exit 1
fi

if [ ! -f $HOSTS ] ; then
    echo "File ${HOSTS} was not created"
    exit 1
fi

echo $'127.0.0.1\tlocalhost' > $HOSTS.expected

if ! cmp $HOSTS $HOSTS.expected > /dev/null 2>&1 ; then
    echo "Contents of $HOSTS are incorrect"
    exit 1
fi