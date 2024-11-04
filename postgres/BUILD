load("@rules_foreign_cc//foreign_cc:defs.bzl", "meson")

# NOTE:
# Meson logs: bazel-out/*-fastbuild/bin/postgres/postgres_foreign_cc/Meson.log

meson(
    name = "postgres",
    build_data = [
        "@m4//bin:m4",
        "@flex//bin:flex",
        "@bison//bin:bison",
        "@python_3_12//:python3",
    ],
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
    },
    lib_source = "@postgres_16.4//:src",
    options = {
        "rpath": "false",
    },
    out_binaries = [
        "initdb",
        "postgres",
        "pg_config",
        "pg_isready",
    ],
    # NOTE: including lib in out_data_dirs because even when it's
    # out_lib_dir's default, it's not included in declared_outputs
    out_data_dirs = [
        "lib",
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
)
