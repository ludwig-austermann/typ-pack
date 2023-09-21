#!/usr/bin/env nu
# nushell script to package the package for publishing

def create_folder_if_missing [p: string] {
    if not ($p | path exists) {
        mkdir $p
        print $'(ansi bo)Folder `($p)` created.'
    }
}

def special_copy [p: string, packp: string] {
    let dir = ([$packp ($p | path dirname)] | str join '\')
    create_folder_if_missing $dir
    cp $p $dir --update
}

let package_name = (open typst.toml | get package | get name)
let package_version = (open typst.toml | get package | get version)

let typst_package_path = if ($nu.os-info.name == "windows") {
    '~\AppData\Local\typst\packages\packaging'
} else {
    error make {msg: "Not implemented yet."}
}

let package_path = ([ $typst_package_path $package_name $package_version ] | str join '\' | path expand)

create_folder_if_missing $package_path

try { cp LICENSE $package_path --update } catch { print $'(ansi red)File `LICENSE` is missing. It is required by typst packages.' }
try { cp README.md $package_path --update } catch { print $'(ansi red)File `README.md` is missing. It is required by typst packages.' }
# copy typst.toml
open typst.toml | get package | save ([$package_path "typst.toml"] | str join '\') --force
# copy entrypoint
try { special_copy (open typst.toml | get package | get entrypoint) $package_path}
#copy include
for p in (open typst.toml | get packaging | get include) {
    try {
        special_copy $p $package_path
    } catch {
        print $"(ansi yellow)File\(s\) `($p)` is missing. It is required by own packaging requirement in `typst.toml`."
    }
}