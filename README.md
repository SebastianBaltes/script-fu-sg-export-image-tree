script-fu-sg-export-image-tree
==============================

Save layers of an XCF image to PNG files (in the same directory as original XCF).
Layer modes, offsets, opacity, and hierarchy are saved as a PNG comment (for
later reconstruction, perhaps?).

This is a fork of 
http://chiselapp.com/user/saulgoode/repository/script-fu/artifact/10e49b454da2fbe063460a3787efe658d2e9a1f3

with the following bugfix: Filenames are filtered so that only letters and digits remain. Before special characters in the layer names like / or : lead to errors.

License: GNU GPL
