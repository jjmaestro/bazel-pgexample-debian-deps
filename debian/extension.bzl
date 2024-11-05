"""deb module extension"""

load("//debian:pkg.bzl", "pkg", "pkg_attrs")

def _deb_module_extension_impl(mctx):
    root_direct_deps = []
    root_direct_deps_dev = []

    for mod in mctx.modules:
        for p in mod.tags.pkg:
            pkg(
                name = p.name,
                sha256 = p.sha256,
                url = p.url,
            )

            if mod.is_root:
                if mctx.is_dev_dependency(p):
                    root_direct_deps_dev.append(p.name)
                else:
                    root_direct_deps.append(p.name)

    return mctx.extension_metadata(
        root_module_direct_deps = root_direct_deps,
        root_module_direct_dev_deps = root_direct_deps_dev,
        reproducible = True,
    )

deb = module_extension(
    implementation = _deb_module_extension_impl,
    tag_classes = {
        "pkg": tag_class(
            attrs = pkg_attrs | {
                "name": attr.string(mandatory = True),
            },
        ),
    },
)
