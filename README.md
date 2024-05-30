# typpack
A Tool to package a typst package for publishing.

## How to use
Run the script inside your package with nushell. Add the following to `typst.toml`:
```toml
...
[packaging]
include = []
prescript = ...
postscript = ...
```
where you can include the files to include besides the default files.

The `README.md` files gets `{{PACKAGE VERSION}}` replaced by the package version as given by the `typst.toml`.