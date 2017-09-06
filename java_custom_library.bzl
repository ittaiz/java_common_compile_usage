def _drop_ijar_of_current_target_from_transitive_compile_time_jars(compilation_provider):
  #this simulates the current rules_scala which don't remove the current ijar but rather don't add it
  transitive_compile_time_jars = []
  current_ijar = compilation_provider.compile_jars.to_list()[0]
  for dep in compilation_provider.transitive_compile_time_jars:
    if dep != current_ijar:
      transitive_compile_time_jars.append(dep)
  return depset(transitive_compile_time_jars)

def _impl(ctx):
  deps = [dep[java_common.provider] for dep in ctx.attr.deps]
  exports = [export[java_common.provider] for export in ctx.attr.exports]

  output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")

  compilation_provider = java_common.compile(
    ctx,
    source_files = ctx.files.srcs,
    output = output_jar,
    javac_opts = java_common.default_javac_opts(ctx, java_toolchain_attr = "_java_toolchain"),
    deps = deps,
    exports = exports,
    resources = ctx.files.resources,
    strict_deps = ctx.fragments.java.strict_java_deps,
    java_toolchain = ctx.attr._java_toolchain,
    host_javabase = ctx.attr._host_javabase
  )

  transitive_compile_time_jars = _drop_ijar_of_current_target_from_transitive_compile_time_jars(compilation_provider)
  java_provider = java_common.create_provider(
    compile_time_jars = compilation_provider.compile_jars,
    runtime_jars = compilation_provider.transitive_runtime_jars,
    transitive_compile_time_jars = transitive_compile_time_jars,
  )

  print(ctx.label)
  print(compilation_provider.compile_jars)
  print(compilation_provider.transitive_compile_time_jars)
  print(transitive_compile_time_jars)
  return struct(
    files = depset([output_jar]),
    providers = [java_provider]
  )

java_custom_library = rule(
  implementation = _impl,
  attrs = {
    "srcs": attr.label_list(allow_files=True),
    "deps": attr.label_list(),
    "exports": attr.label_list(),
    "resources": attr.label_list(allow_files=True),
    "_java_toolchain": attr.label(default = Label("@bazel_tools//tools/jdk:toolchain")),
    "_host_javabase": attr.label(default = Label("//tools/defaults:jdk"))
  },
  fragments = ["java"]
)
