load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

"""TensorFlow Bazel dependencies."""

_SINGLE_URL_ALLOWLIST = depset([
    "arm_compiler",
])

def _is_windows(ctx):
    return ctx.os.name.lower().find("windows") != -1

def _wrap_bash_cmd(ctx, cmd):
    if _is_windows(ctx):
        bazel_sh = _get_env_var(ctx, "BAZEL_SH")
        if not bazel_sh:
            fail("BAZEL_SH environment variable is not set")
        cmd = [bazel_sh, "-l", "-c", " ".join(["\"%s\"" % s for s in cmd])]
    return cmd

def _get_env_var(ctx, name):
    if name in ctx.os.environ:
        return ctx.os.environ[name]
    else:
        return None

# Checks if we should use the system lib instead of the bundled one
def _use_system_lib(ctx, name):
    syslibenv = _get_env_var(ctx, "TF_SYSTEM_LIBS")
    if syslibenv:
        for n in syslibenv.strip().split(","):
            if n.strip() == name:
                return True
    return False

# Executes specified command with arguments and calls 'fail' if it exited with
# non-zero code
def _execute_and_check_ret_code(repo_ctx, cmd_and_args):
    result = repo_ctx.execute(cmd_and_args, timeout = 60)
    if result.return_code != 0:
        fail(("Non-zero return code({1}) when executing '{0}':\n" + "Stdout: {2}\n" +
              "Stderr: {3}").format(
            " ".join([str(x) for x in cmd_and_args]),
            result.return_code,
            result.stdout,
            result.stderr,
        ))

# Apply a patch_file to the repository root directory
# Runs 'patch -p1' on both Windows and Unix.
def _apply_patch(ctx, patch_file):
    patch_command = ["patch", "-p1", "-d", ctx.path("."), "-i", ctx.path(patch_file)]
    cmd = _wrap_bash_cmd(ctx, patch_command)
    _execute_and_check_ret_code(ctx, cmd)

def _apply_delete(ctx, paths):
    for path in paths:
        if path.startswith("/"):
            fail("refusing to rm -rf path starting with '/': " + path)
        if ".." in path:
            fail("refusing to rm -rf path containing '..': " + path)
    cmd = _wrap_bash_cmd(ctx, ["rm", "-rf"] + [ctx.path(path) for path in paths])
    _execute_and_check_ret_code(ctx, cmd)

def _third_party_http_archive(ctx):
    if ("mirror.tensorflow.org" not in ctx.attr.urls[0] and
        (len(ctx.attr.urls) < 2 and
         ctx.attr.name not in _SINGLE_URL_ALLOWLIST.to_list())):
        fail("tf_http_archive(urls) must have redundant URLs. The " +
             "mirror.tensorflow.org URL must be present and it must come first. " +
             "Even if you don't have permission to mirror the file, please " +
             "put the correctly formatted mirror URL there anyway, because " +
             "someone will come along shortly thereafter and mirror the file.")

    use_syslib = _use_system_lib(ctx, ctx.attr.name)

    # Use "BUILD.bazel" to avoid conflict with third party projects that contain a
    # file or directory called "BUILD"
    buildfile_path = ctx.path("BUILD.bazel")

    if use_syslib:
        if ctx.attr.system_build_file == None:
            fail("Bazel was configured with TF_SYSTEM_LIBS to use a system " +
                 "library for %s, but no system build file for %s was configured. " +
                 "Please add a system_build_file attribute to the repository rule" +
                 "for %s." % (ctx.attr.name, ctx.attr.name, ctx.attr.name))
        ctx.symlink(Label(ctx.attr.system_build_file), buildfile_path)

    else:
        ctx.download_and_extract(
            ctx.attr.urls,
            "",
            ctx.attr.sha256,
            ctx.attr.type,
            ctx.attr.strip_prefix,
        )
        if ctx.attr.delete:
            _apply_delete(ctx, ctx.attr.delete)
        if ctx.attr.patch_file != None:
            _apply_patch(ctx, ctx.attr.patch_file)
        ctx.symlink(Label(ctx.attr.build_file), buildfile_path)

    link_dict = {}
    if use_syslib:
        link_dict.update(ctx.attr.system_link_files)

    for internal_src, external_dest in ctx.attr.link_files.items():
        # if syslib and link exists in both, use the system one
        if external_dest not in link_dict.values():
            link_dict[internal_src] = external_dest

    for internal_src, external_dest in link_dict.items():
        ctx.symlink(Label(internal_src), ctx.path(external_dest))

# For link_files, specify each dict entry as:
# "//path/to/source:file": "localfile"
third_party_http_archive = repository_rule(
    attrs = {
        "sha256": attr.string(mandatory = True),
        "urls": attr.string_list(
            mandatory = True,
            allow_empty = False,
        ),
        "strip_prefix": attr.string(),
        "type": attr.string(),
        "delete": attr.string_list(),
        "build_file": attr.string(mandatory = True),
        "system_build_file": attr.string(mandatory = False),
        "patch_file": attr.label(),
        "link_files": attr.string_dict(),
        "system_link_files": attr.string_dict(),
    },
    environ = [
        "TF_SYSTEM_LIBS",
    ],
    implementation = _third_party_http_archive
)

def _find_tf_include_path(repo_ctx):
    exec_result = repo_ctx.execute(
        [
            "python3",
            "-c",
            "import tensorflow as tf; import sys; " +
            "sys.stdout.write(tf.sysconfig.get_include())",
        ],
        quiet = True,
    )
    if exec_result.return_code != 0:
        fail("Could not locate tensorflow installation path.")
    return exec_result.stdout.splitlines()[-1]

def _find_tf_lib_path(repo_ctx):
    exec_result = repo_ctx.execute(
        [
            "python3",
            "-c",
            "import tensorflow as tf; import sys; " +
            "sys.stdout.write(tf.sysconfig.get_lib())",
        ],
        quiet = True,
    )
    if exec_result.return_code != 0:
        fail("Could not locate tensorflow installation path.")
    return exec_result.stdout.splitlines()[-1]

def _eigen_archive_repo_impl(repo_ctx):
    tf_include_path = _find_tf_include_path(repo_ctx)
    repo_ctx.symlink(tf_include_path, "tf_includes")
    repo_ctx.file(
        "BUILD",
        content = """
cc_library(
    name = "includes",
    hdrs = glob(["tf_includes/Eigen/**/*.h",
                 "tf_includes/Eigen/**",
                 "tf_includes/unsupported/Eigen/**/*.h",
                 "tf_includes/unsupported/Eigen/**"]),
    # https://groups.google.com/forum/#!topic/bazel-discuss/HyyuuqTxKok
    includes = ["tf_includes"],
    visibility = ["//visibility:public"],
)
""",
        executable = False,
    )

def _absl_includes_repo_impl(repo_ctx):
    tf_include_path = _find_tf_include_path(repo_ctx)
    repo_ctx.symlink(
        tf_include_path + "/absl",
        "absl",
    )
    repo_ctx.file(
        "BUILD",
        content = """
cc_library(
    name = "includes",
    hdrs = glob(["absl/**/*.h",
                 "absl/**/*.inc"]),
    includes = ["absl"],
    visibility = ["//visibility:public"],
)
""",
        executable = False,
    )

def _zlib_includes_repo_impl(repo_ctx):
    tf_include_path = _find_tf_include_path(repo_ctx)
    repo_ctx.symlink(
        tf_include_path + "/external/zlib",
        "zlib",
    )
    repo_ctx.file(
        "BUILD",
        content = """
cc_library(
    name = "includes",
    hdrs = glob(["zlib/**/*.h"]),
    includes = ["zlib"],
    visibility = ["//visibility:public"],
)
""",
        executable = False,
    )

def _protobuf_includes_repo_impl(repo_ctx):
    tf_include_path = _find_tf_include_path(repo_ctx)
    repo_ctx.symlink(tf_include_path, "tf_includes")
    repo_ctx.file(
        "BUILD",
        content = """
cc_library(
    name = "includes",
    hdrs = glob(["tf_includes/google/protobuf/*.h",
                 "tf_includes/google/protobuf/*.inc",
                 "tf_includes/google/protobuf/**/*.h",
                 "tf_includes/google/protobuf/**/*.inc"]),
    includes = ["tf_includes"],
    visibility = ["//visibility:public"],
)
""",
        executable = False,
    )

def _tensorflow_includes_repo_impl(repo_ctx):
    tf_include_path = _find_tf_include_path(repo_ctx)
    repo_ctx.symlink(tf_include_path, "tensorflow_includes")
    repo_ctx.file(
        "BUILD",
        content = """
cc_library(
    name = "includes",
    hdrs = glob(["tensorflow_includes/**/*.h",
                 "tensorflow_includes/third_party/eigen3/**"]),
    includes = ["tensorflow_includes"],
    deps = ["@absl_includes//:includes",
            "@eigen_archive//:includes",
            "@protobuf_archive//:includes",
            "@zlib_includes//:includes",],
    visibility = ["//visibility:public"],
)
""",
        executable = False,
    )

def _tensorflow_solib_repo_impl(repo_ctx):
    tf_lib_path = _find_tf_lib_path(repo_ctx)
    repo_ctx.symlink(tf_lib_path, "tensorflow_solib")
    repo_ctx.file(
        "BUILD",
        content = """
cc_library(
    name = "framework_lib",
    srcs = ["tensorflow_solib/libtensorflow_framework.so.2"],
    visibility = ["//visibility:public"],
)
""",
    )

def cc_tf_configure():
    """Autoconf pre-installed tensorflow repo."""
    make_eigen_repo = repository_rule(implementation = _eigen_archive_repo_impl)
    make_eigen_repo(name = "eigen_archive")
    make_absl_repo = repository_rule(
        implementation = _absl_includes_repo_impl,
    )
    make_absl_repo(name = "absl_includes")
    make_zlib_repo = repository_rule(
        implementation = _zlib_includes_repo_impl,
    )
    make_zlib_repo(name = "zlib_includes")
    make_protobuf_repo = repository_rule(
        implementation = _protobuf_includes_repo_impl,
    )
    make_protobuf_repo(name = "protobuf_archive")
    make_tfinc_repo = repository_rule(
        implementation = _tensorflow_includes_repo_impl,
    )
    make_tfinc_repo(name = "tensorflow_includes")
    make_tflib_repo = repository_rule(
        implementation = _tensorflow_solib_repo_impl,
    )
    make_tflib_repo(name = "tensorflow_solib")

def icu():
    third_party_http_archive(
        name = "icu",
        strip_prefix = "icu-release-64-2",
        sha256 = "dfc62618aa4bd3ca14a3df548cd65fe393155edd213e49c39f3a30ccd618fc27",
        urls = [
            "https://storage.googleapis.com/mirror.tensorflow.org/github.com/unicode-org/icu/archive/release-64-2.zip",
            "https://github.com/unicode-org/icu/archive/release-64-2.zip",
        ],
        build_file = "//third_party/icu:BUILD.bazel",
        system_build_file = "//third_party/icu:BUILD.system",
        patch_file = "//third_party/icu:udata.patch",
    )