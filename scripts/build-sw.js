const fs = require('fs');
const path = require('path');

// Read package.json to get version
const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
const version = packageJson.version;

// Read service worker template
const templatePath = 'sw-template.js';
let swContent = fs.readFileSync(templatePath, 'utf8');

// Replace version placeholder
swContent = swContent.replace(/{{version}}/g, version);

// Create dist directory if it doesn't exist
const distDir = 'dist';
if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir);
}

// Write final service worker to dist
const outputPath = path.join(distDir, 'sw.js');
fs.writeFileSync(outputPath, swContent);

console.log(`Service worker built successfully with version ${version}`);