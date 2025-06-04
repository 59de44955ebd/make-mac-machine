APP_NAME=make-mac-machine

cd "$(dirname "$0")"

rm -R "dist/$APP_NAME" 2>/dev/null

echo
echo '****************************************'
echo 'Running pyinstaller...'
echo '****************************************'

pyinstaller --noupx -n "$APP_NAME" -D main.py --exclude-module _bootlocale

echo
echo '****************************************'
echo 'Copying resources...'
echo '****************************************'

cp -R ../bin-mac "dist/$APP_NAME/_internal/bin"
cp -R ../dsk "dist/$APP_NAME/_internal/dsk"
cp -R ../vmx "dist/$APP_NAME/_internal/vmx"

echo
echo '****************************************'
echo 'Optimizing application...'
echo '****************************************'

rm "dist/$APP_NAME/_internal/libcrypto.3.dylib"
rm "dist/$APP_NAME/_internal/libssl.3.dylib"

echo
echo '****************************************'
echo 'Creating ZIP...'
echo '****************************************'

cd dist
rm "$APP_NAME-macos.zip" 2>/dev/null
zip -q -r "$APP_NAME-standalone-macos.zip" "$APP_NAME"
cd ..

echo
echo '****************************************'
echo 'Done.'
echo '****************************************'
echo
