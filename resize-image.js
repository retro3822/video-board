const sharp = require('sharp');
const path = require('path');

/**
 * Resize an image file to specified dimensions
 * @param {string} inputPath - Path to the input image
 * @param {string} outputPath - Path to save the resized image
 * @param {Object} options - Resize options
 * @param {number} options.width - Target width in pixels
 * @param {number} options.height - Target height in pixels
 * @param {string} options.fit - Fit mode: 'cover', 'contain', 'fill', 'inside', 'outside' (default: 'cover')
 * @param {boolean} options.withoutEnlargement - Don't enlarge if smaller than target (default: false)
 * @returns {Promise<Object>} Info about the resized image
 */
async function resizeImage(inputPath, outputPath, options = {}) {
  try {
    const {
      width = 800,
      height = 600,
      fit = 'cover',
      withoutEnlargement = false,
      quality = 80
    } = options;

    const resizeOptions = {
      width,
      height,
      fit,
      withoutEnlargement
    };

    const info = await sharp(inputPath)
      .resize(resizeOptions)
      .jpeg({ quality }) // You can change this based on output format
      .toFile(outputPath);

    console.log(`✓ Image resized successfully!`);
    console.log(`  Input: ${inputPath}`);
    console.log(`  Output: ${outputPath}`);
    console.log(`  Dimensions: ${info.width}x${info.height}`);
    console.log(`  Size: ${(info.size / 1024).toFixed(2)} KB`);

    return info;
  } catch (error) {
    console.error('Error resizing image:', error.message);
    throw error;
  }
}

/**
 * Resize multiple images at once
 * @param {Array} images - Array of {input, output, options} objects
 * @returns {Promise<Array>} Array of resize results
 */
async function resizeMultipleImages(images) {
  const results = [];

  for (const image of images) {
    try {
      const info = await resizeImage(image.input, image.output, image.options);
      results.push({ success: true, info });
    } catch (error) {
      results.push({ success: false, error: error.message });
    }
  }

  return results;
}

// CLI usage
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.log('Usage: node resize-image.js <input> <output> [width] [height]');
    console.log('Example: node resize-image.js input.jpg output.jpg 800 600');
    process.exit(1);
  }

  const [input, output, width, height] = args;

  const options = {
    width: width ? parseInt(width) : 800,
    height: height ? parseInt(height) : 600,
    fit: 'cover'
  };

  resizeImage(input, output, options)
    .then(() => process.exit(0))
    .catch(() => process.exit(1));
}

module.exports = { resizeImage, resizeMultipleImages };
