elm make src/Main.elm --output=dist/index.html

# Inject CSS into the HTML
sed -i '' 's|<style>body { padding: 0; margin: 0; }</style>|<style>body { padding: 0; margin: 0; }</style>\n<style>'"$(cat src/styles.css | tr '\n' ' ')"'</style>|' dist/index.html