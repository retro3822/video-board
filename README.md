# video-board

Image and video processing utilities for resizing and optimizing media files.

## Image Resizing

This project includes a powerful image resizing utility using the Sharp library.

### Installation

```bash
npm install
```

### Usage

#### Command Line

```bash
node resize-image.js <input> <output> [width] [height]
```

**Example:**
```bash
node resize-image.js input.jpg output.jpg 800 600
```

#### Programmatic Usage

```javascript
const { resizeImage } = require('./resize-image');

// Resize an image
await resizeImage('input.jpg', 'output.jpg', {
  width: 800,
  height: 600,
  fit: 'cover',        // Options: 'cover', 'contain', 'fill', 'inside', 'outside'
  quality: 80,         // JPEG quality (1-100)
  withoutEnlargement: false
});
```

### Options

- **width**: Target width in pixels (default: 800)
- **height**: Target height in pixels (default: 600)
- **fit**: How the image should fit the target dimensions
  - `cover`: Crop to cover both dimensions (default)
  - `contain`: Maintain aspect ratio, fit within dimensions
  - `fill`: Stretch to fill dimensions (ignores aspect ratio)
  - `inside`: Resize to be inside dimensions, maintaining aspect ratio
  - `outside`: Resize to be outside dimensions, maintaining aspect ratio
- **quality**: Output quality for JPEG (1-100, default: 80)
- **withoutEnlargement**: Don't enlarge if image is smaller than target (default: false)

### Examples

See `example-usage.js` for more detailed examples including:
- Simple resizing
- Creating thumbnails
- Batch processing multiple images
- Different fit modes

### Features

- Fast and memory-efficient image processing
- Support for various image formats (JPEG, PNG, WebP, TIFF, etc.)
- Multiple resize modes to fit your needs
- Batch processing support
- Quality control
- No enlargement option for optimization

### Requirements

- Node.js 14 or higher
- npm or yarn
