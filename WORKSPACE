workspace(name = "spleeter")

load("@spleeter//third_party/tensorflow:tensorflow.bzl", "cc_tf_configure", "icu")
load("@spleeter//third_party:dependencies.bzl", "spleeter_dependencies")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

cc_tf_configure()
icu()
spleeter_dependencies()

load("@tensorflowlite//third_party:dependencies.bzl", "tensorflowlite_dependencies")

tensorflowlite_dependencies()

load("@tensorflow//third_party:dependencies.bzl", "tensorflow_dependencies")

tensorflow_dependencies()
