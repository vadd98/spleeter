load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def bazel_deps_repository():
    commit = "XXX"
    http_archive(
        name = "com_github_mjbots_bazel_deps",
        url = "https://github.com/mjbots/bazel_deps/archive/{}.zip".format(commit),
        # Try the following empty sha256 hash first, then replace with whatever
        # bazel says it is looking for once it complains.
        sha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        strip_prefix = "bazel_deps-{}".format(commit),
    )