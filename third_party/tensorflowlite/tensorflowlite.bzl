load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def tensorflowlite():
    """ Load TensorFlow Lite as Dependency """
    if "tensorflowlite" not in native.existing_rules():
        http_archive(
            name = "tensorflowlite",
            sha256 = "040ac8e5c98932c8c9e54fab5c973e47108e50687c8066b0f01328eadfc6e1b9",
            url = "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-windows-x86_64-2.7.0.zip",
        )
