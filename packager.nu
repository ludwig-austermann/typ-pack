#!/usr/bin/env nu
# nushell script to package the package for publishing

def create_folder_if_missing [p: string] {
    if not ($p | path exists) {
        mkdir $p
        print $'(ansi bo)[Packaging] Folder `($p)` created.'
    }
}

def special_copy [p: string, packp: string] {
    let dir = $packp + '\' + ($p | path dirname)
    create_folder_if_missing $dir
    cp ($p | into glob) $dir --update
    print $'(ansi bo)[Packaging] `($p)` copied.'
}

def script_run [script_name: string, pack: record] {
    try {
        let script_path = $pack.packaging | get $script_name
        let dir = $script_path | path dirname
        let script = $script_path | path basename
        print $"(ansi yellow)[Packaging] Running ($script_name) `($script)` at ($dir)."
        with-env [ PWD ((pwd) + '\' + $dir) ] {
            nu $script
        }
        print $"(ansi yellow)[Packaging] ($script_name) finished."
    }
}

let typst_toml = open typst.toml

script_run prescript $typst_toml

let package_name = $typst_toml.package.name
let package_version = $typst_toml.package.version

let typst_package_path = if ($nu.os-info.name == "windows") {
    '~\AppData\Local\typst\packages\packaging'
} else {
    error make { msg: "Not implemented yet." }
}

let package_path = [ $typst_package_path $package_name $package_version ] | str join '\' | path expand

create_folder_if_missing $package_path

try { cp LICENSE $package_path --update } catch { print $'(ansi red)[Packaging] File `LICENSE` is missing. It is required by typst packages.' }
try {
    open README.md | str replace "{{PACKAGE VERSION}}" $package_version --all | save ($package_path + "/README.md")
} catch { print $'(ansi red)[Packaging] File `README.md` is missing. It is required by typst packages.' }
# copy typst.toml
$typst_toml | select package | save ($package_path + '\typst.toml') --force
# copy entrypoint
try { special_copy ($typst_toml.package.entrypoint) $package_path}
#copy include
try {
    for p in ($typst_toml.packaging.include) {
        try {
            special_copy $p $package_path
        } catch {
            print $"(ansi yellow)[Packaging] File\(s\) `($p)` is missing. It is required by own packaging requirement in `typst.toml`."
        }
    }
}

script_run postscript $typst_toml

print $"(ansi green)[Packaging] Done."
