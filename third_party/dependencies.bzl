load("@spleeter//third_party/audio_example:audio_example.bzl", "audio_example")
load("@spleeter//third_party/audionamix:audionamix.bzl", "audionamix")
load("@spleeter//third_party/eigen:eigen.bzl", "eigen")
load("@spleeter//third_party/glog:glog.bzl", "glog")
load("@spleeter//third_party/googletest:googletest.bzl", "googletest")
load("@spleeter//third_party/models:models.bzl", "models")
load("@spleeter//third_party/nlohmann:nlohmann.bzl", "nlohmann")
load("@spleeter//third_party/zlib:zlib.bzl", "zlib")

def spleeter_dependencies():
    """ Load 3rd Party Dependencies """
    audio_example()
    audionamix()
    eigen()
    glog()
    googletest()
    models()
    nlohmann()
    zlib()
