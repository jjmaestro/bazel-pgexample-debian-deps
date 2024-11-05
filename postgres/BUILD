load("@rules_foreign_cc//foreign_cc:defs.bzl", "meson")
load("//debian:ccinfo.bzl", "gen_ccinfo_from_deb")

CPU_ARCH = {
    "arm64": "arm64",
    "x86_64": "amd64",
}

DEPZ = [
    "libssl3_3.1.5",
    "libssl_3.4.0",
]

[
    gen_ccinfo_from_deb(
        name = "ccinfo_{}_{}".format(p, arch),
        dep = "@{}_{}//:files".format(p, arch),
    )
    for p in DEPZ
    for arch in CPU_ARCH.values()
]

DEPS = select({
    "@platforms//cpu:{}".format(cpu): [
        "ccinfo_{}_{}".format(p, arch)
        for p in DEPZ
    ]
    for cpu, arch in CPU_ARCH.items()
})

# NOTE:
# Meson logs: bazel-out/*-fastbuild/bin/postgres/postgres_foreign_cc/Meson.log

meson(
    name = "meson",
    build_data = [
        "@m4//bin:m4",
        "@flex//bin:flex",
        "@bison//bin:bison",
        "@python_3_12//:python3",
    ] + DEPS,
    env = {
        # NOTE:
        # The flex binary from rules_flex doesn't have a macro processor
        # defined at compile time so we point it at the rules_m4 binary
        # (flex honors the M4 env variable)
        "M4": "$(execpath @m4//bin:m4)",
        # NOTE:
        # Meson seems to search for the tools by name in the PATH, unlike
        # configure where you usually have an env variable named like the
        # tool pointing to the binary itself (e.g. PERL="/foo/bar/perl").
        # Thus, we use dirname on the execpath that points to the binary.
        "PATH": ":".join([
            "$$(dirname $(execpath @python_3_12//:python3))",
            "$$(dirname $(PERL))",
            "$$(dirname $(execpath @m4//bin:m4))",
            "$$(dirname $(execpath @flex//bin:flex))",
            "$$(dirname $(execpath @bison//bin:bison))",
            "$$PATH",
        ]),
        # NOTE:
        # https://github.com/jmillikin/rules_bison/issues/17#issuecomment-2399677539
        #
        # I'm not sure who's responsible (Bazel or rules_foreign_cc) but
        # rules_foreign_cc meson is using a wrapper script that does some
        # runfiles initialization that ends up being wrong: it points to
        # the Meson runfiles dir when running tools from Meson and Bison
        # can't find some of its data files.
        #
        # After looking at the rules_foreign_cc wrapper script in
        # bazel-contrib/rules_foreign_cc/blob/0.12.0/foreign_cc/private/runnable_binary_wrapper.sh
        # we can force-set the RUNFILES_DIR
        "RUNFILES_DIR": "$(execpath @bison//bin:bison).runfiles/",

        # trying to get dependencies to work...
        #"CFLAGS": " ".join([
        #    "$${CFLAGS:-}",
        #    "-I$$EXT_BUILD_DEPS/include",
        #    "-I$$EXT_BUILD_DEPS/include/aarch64-linux-gnu",
        #]),
        #"LDFLAGS": " ".join([
        #    "$${LDFLAGS:-}",
        # this is weird, when I use the hardcoded sandbox path it works
        # "more" than when I use the non-sandbox one o.0 and I know for a
        # fact that the sandboxed path "is missing" stuff (broken symlinks)
        #"-L/root/.cache/bazel/_bazel_root/a08c2e4811c846650b733c6fc815a920/sandbox/processwrapper-sandbox/400/execroot/_main/external/_main~deb~libssl3_3.1.5_arm64/files/usr/lib/aarch64-linux-gnu",
        #"-L/root/.cache/bazel/_bazel_root/a08c2e4811c846650b733c6fc815a920/sandbox/processwrapper-sandbox/400/execroot/_main/external/_main~deb~libssl_3.4.0_arm64/files/usr/lib/aarch64-linux-gnu",
        #"-L/root/.cache/bazel/_bazel_root/a08c2e4811c846650b733c6fc815a920/execroot/_main/external/_main~deb~libssl3_3.1.5_arm64/files/usr/lib/aarch64-linux-gnu",
        #"-L/root/.cache/bazel/_bazel_root/a08c2e4811c846650b733c6fc815a920/execroot/_main/external/_main~deb~libssl_3.4.0_arm64/files/usr/lib/aarch64-linux-gnu",
        #"""$$(echo $(locations @libssl_3.4.0_arm64//:files) | tr ' ' '\n' | grep '\\.so' | xargs dirname | sort | uniq | xargs -I% echo "-L$$EXT_BUILD_ROOT/%@" | xargs | tr -d "@")""",
        #"""$$(echo $(locations @libssl3_3.1.5_arm64//:files) | tr ' ' '\n' | grep '\\.so' | xargs dirname | sort | uniq | xargs -I% echo "-L$$EXT_BUILD_ROOT/%@" | xargs | tr -d "@")""",
        #"-L/tmp/foo",
        #]),
    },
    lib_source = "@postgres_16.4//:src",
    options = {
        "rpath": "false",
        "ssl": "openssl",
    },
    out_binaries = [
        "initdb",
        "postgres",
        "pg_config",
        "pg_isready",
    ],
    out_data_dirs = [
        "share",
    ],
    setup_args = [
        "--auto-features=disabled",
    ],
    toolchains = [
        "@rules_perl//:current_toolchain",
        "@rules_m4//m4:current_m4_toolchain",
        "@rules_flex//flex:current_flex_toolchain",
        "@rules_bison//bison:current_bison_toolchain",
    ],
    deps = DEPS,
)

filegroup(
    name = "postgres",
    srcs = [":meson"],
    output_group = "gen_dir",
)
