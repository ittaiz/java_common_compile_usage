package(default_visibility = ["//visibility:public"])
load(":java_custom_library.bzl", "java_custom_library")

java_custom_library(
    name="transitive_dependency_user",
    srcs=[
        "A.java",
        ],
    deps = ["direct_dependency"],    
)

java_custom_library(
    name="direct_dependency",
    srcs=[
        "B.java",
        ],
    deps = ["transitive_dependency"],
)

java_custom_library(
    name="transitive_dependency",
    srcs=[
        "C.java",
        ],
)
