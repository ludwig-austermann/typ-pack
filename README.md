# typpack
A Tool to package a typst package for publishing.

## How to use
Run the script inside your package with nushell. Add the following to `typst.toml`:
```toml
...
[packaging]
include = []
```
where you can include the files to include besides the default files.