"""debian ccinfo"""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

def _gen_ccinfo_from_deb_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    files = ctx.attr.dep[DefaultInfo].files

    if not files:
        return []

    headers = [
        file
        for file in files.to_list()
        if file.path.endswith(".h")
    ]

    # TODO: this needs to work for other libraries...
    includes = [
        file.dirname.split("/openssl")[0]
        for file in files.to_list()
        if file.path.endswith(".h")
    ]

    # NOTE: using this fake path to debug rules_foreign_cc scripts / logs
    includes.append("/tmp/ccinfo_debug")

    compilation_context = cc_common.create_compilation_context(
        headers = depset(headers),
        includes = depset(includes),
    )

    libraries = [
        file
        for file in files.to_list()
        if file.path.endswith(".so")
    ]

    libraries_to_link = [
        cc_common.create_library_to_link(
            actions = ctx.actions,
            feature_configuration = feature_configuration,
            dynamic_library = lib,
            cc_toolchain = cc_toolchain,
        )
        for lib in libraries
    ]

    linker_input = cc_common.create_linker_input(
        owner = ctx.label,
        libraries = depset(libraries_to_link),
    )

    linking_context = cc_common.create_linking_context(
        linker_inputs = depset([linker_input]),
    )

    return [
        ctx.attr.dep[DefaultInfo],
        CcInfo(
            compilation_context = compilation_context,
            linking_context = linking_context,
        ),
    ]
    # NOTE: will I have to merge all of the CcInfo for all the tars!?
    # https://github.com/bazelbuild/rules_cc/blob/a5827bf372d12b684f629198ba195aa2f72075e8/examples/my_c_archive/my_c_archive.bzl

gen_ccinfo_from_deb = rule(
    implementation = _gen_ccinfo_from_deb_impl,
    attrs = {
        "dep": attr.label(),
        # we need to declare this attribute to access cc_toolchain
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    fragments = ["cpp"],
    toolchains = [
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
)
