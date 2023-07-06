// require modules
const fs = require('fs');
const archiver = require('archiver');
const path = require("path")

// create a file to stream archive data to.
console.log('||====================================================================||');
console.log('Starting to create opcua-browser.zip archive from `/dist` folder...');

const archivePath = path.join(__dirname, process.argv.length< 3 ? "opcua-browser.zip" : process.argv[2])
const output = fs.createWriteStream(archivePath)
const archive = archiver('zip', {
  zlib: { level: 9 } // Sets the compression level.
});

// listen for all archive data to be written
// 'close' event is fired only when a file descriptor is involved
output.on('close', function() {
  console.log('Zip file created: ' + archive.pointer() + ' total bytes');
  console.log('Successfully created opcua-browser.zip archive from dist folder.');
});

// This event is fired when the data source is drained no matter what was the data source.
// It is not part of this library but rather from the NodeJS Stream API.
// @see: https://nodejs.org/api/stream.html#stream_event_end
output.on('end', function() {
  console.log('Data has been drained');
});

// good practice to catch warnings (ie stat failures and other non-blocking errors)
archive.on('warning', function(err) {
  if (err.code === 'ENOENT') {
    // log warning
  } else {
    // throw error
    throw err;
  }
});

// good practice to catch this error explicitly
archive.on('error', function(err) {
  throw err;
});

// pipe archive data to the file
archive.pipe(output);

// append files from a sub-directory, putting its contents at the root of archive
const dirPath = process.argv.length< 4 ? "dist" : process.argv[3]
archive.directory(dirPath, false);

// finalize the archive (ie we are done appending files but streams have to finish yet)
// 'close', 'end' or 'finish' may be fired right after calling this method so register to them beforehand
archive.finalize();
