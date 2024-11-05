"""deb pkg"""

load("@aspect_bazel_lib//lib:repo_utils.bzl", "repo_utils")

PKG_BUILD_FILE = '''
filegroup(
    name = "data",
    srcs = glob(["data.tar*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "files",
    # TODO: is there a way to fix this?
    # e.g. liberror-perl has files such as:
    # /usr/share/man/man3/Error::Simple.3pm.gz
    srcs = glob(["files/**"], exclude=["files/**/*:*"]),
    visibility = ["//visibility:public"],
)
'''

def _pkg_impl(rctx):
    rctx.download_and_extract(
        url = rctx.attr.url,
        sha256 = rctx.attr.sha256,
    )
    rctx.file("BUILD", PKG_BUILD_FILE)

    # get the data file to extract
    # NOTE: is there a better way to do this in Bazel?
    res = rctx.execute(["bash", "-c", "echo *"])
    data = [
        f
        for f in res.stdout.strip().split(" ")
        if f.startswith("data.tar")
    ]
    if len(data) != 1:
        fail("Can't find data.tar file in %s!" % rctx.name)

    # TODO: use a POSIX hermetic chain to avoid depending on systems tools
    rctx.execute(["mkdir", "files"])

    tar = Label("@bsd_tar_{}//:tar{}".format(
        repo_utils.platform(rctx),
        ".exe" if repo_utils.is_windows(rctx) else "",
    ))

    rctx.execute([tar, "-xzf", data[0], "-C", "files"])

pkg_attrs = {
    "sha256": attr.string(mandatory = True),
    "url": attr.string(mandatory = True),
}

pkg = repository_rule(
    implementation = _pkg_impl,
    attrs = pkg_attrs,
)
