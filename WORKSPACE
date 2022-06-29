workspace(name = "spleeter")

load("@spleeter//third_party:dependencies.bzl", "spleeter_dependencies")
load("@spleeter//third_party/tensorflow_http_archive:tensorflow_http_archive.bzl", "tensorflow_http_archive")


# ===== TensorFlow dependency =====

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

# ===== TensorFlow dependency end =====


# initializing spleeter dependencies
spleeter_dependencies()
