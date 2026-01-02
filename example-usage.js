const { resizeImage, resizeMultipleImages } = require('./resize-image');

// Example 1: Simple resize
async function example1() {
  await resizeImage('input.jpg', 'output.jpg', {
    width: 800,
    height: 600,
    fit: 'cover'
  });
}

// Example 2: Resize maintaining aspect ratio (contain)
async function example2() {
  await resizeImage('input.jpg', 'thumbnail.jpg', {
    width: 200,
    height: 200,
    fit: 'contain',
    quality: 90
  });
}

// Example 3: Resize without enlargement
async function example3() {
  await resizeImage('input.jpg', 'optimized.jpg', {
    width: 1920,
    height: 1080,
    fit: 'inside',
    withoutEnlargement: true,
    quality: 85
  });
}

// Example 4: Batch resize multiple images
async function example4() {
  const images = [
    {
      input: 'photo1.jpg',
      output: 'photo1-resized.jpg',
      options: { width: 800, height: 600 }
    },
    {
      input: 'photo2.jpg',
      output: 'photo2-resized.jpg',
      options: { width: 800, height: 600 }
    }
  ];

  const results = await resizeMultipleImages(images);
  console.log('Batch resize results:', results);
}

// Run examples (uncomment the one you want to test)
// example1();
// example2();
// example3();
// example4();
