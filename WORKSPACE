workspace(name = "spleeter")

load("@spleeter//third_party:dependencies.bzl", "spleeter_dependencies")




# To update TensorFlow to a new revision.
# 1. Update the 'git_commit' args below to include the new git hash.
# 2. Get the sha256 hash of the archive with a command such as...
#    curl -L https://github.com/tensorflow/tensorflow/archive/<git hash>.tar.gz | sha256sum
#    and update the 'sha256' arg with the result.
# 3. Request the new archive to be mirrored on mirror.bazel.build for more
#    reliable downloads.
load("@spleeter//third_party/tensorflow_http_archive:repo.bzl", "tensorflow_http_archive")


# ===== TensorFlow dependency =====
#
# TensorFlow is imported here instead of in tf_serving_workspace() because
# existing automation scripts that bump the TF commit hash expect it here.
#
# To update TensorFlow to a new revision.
# 1. Update the 'git_commit' args below to include the new git hash.
# 2. Get the sha256 hash of the archive with a command such as...
#    curl -L https://github.com/tensorflow/tensorflow/archive/<git hash>.tar.gz | sha256sum
#    and update the 'sha256' arg with the result.
# 3. Request the new archive to be mirrored on mirror.bazel.build for more
#    reliable downloads.
load("@spleeter//third_party/tensorflow_http_archive:repo.bzl", "tensorflow_http_archive")
tensorflow_http_archive(
    name = "org_tensorflow",
    sha256 = "a8b033346ac509ef2bf8b507bb7360dd2d90f8bad497b86bf9a960b54f2db924",
    git_commit = "bfd98ceecbcc884c680e7e425609e206b3c06241",
)

# Check bazel version requirement, which is stricter than TensorFlow's.
load(
    "@org_tensorflow//tensorflow:version_check.bzl",
    "check_bazel_version_at_least"
)
check_bazel_version_at_least("5.1.1")

# Initialize TensorFlow's external dependencies.
load("@org_tensorflow//tensorflow:workspace3.bzl", "workspace")
workspace()
load("@org_tensorflow//tensorflow:workspace2.bzl", "workspace")
workspace()
load("@org_tensorflow//tensorflow:workspace1.bzl", "workspace")
workspace()
load("@org_tensorflow//tensorflow:workspace0.bzl", "workspace")
workspace()

# Initialize bazel package rules' external dependencies.
load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
rules_pkg_dependencies()

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

rules_proto_dependencies()
rules_proto_toolchains()




# using bazel_deps for ffmpeg dependency
load("@spleeter//third_party/bazel_deps:repository.bzl", "bazel_deps_repository")
bazel_deps_repository()

load("@com_github_mjbots_bazel_deps//tools/workspace:default.bzl",
     bazel_deps_add = "add_default_repositories")
bazel_deps_add()


# tensorflow and tensorflowlite
#load("@org_tensorflow//tensorflow:tensorflow.bzl", "tf_cc_shared_object")
#load("@org_tensorflow//tensorflow/lite:build_def.bzl", "tflite_cc_shared_object")
#
#tf_cc_shared_object("tensorflow.dll")
#tflite_cc_shared_object("tensorflowlite.dll")


spleeter_dependencies()
