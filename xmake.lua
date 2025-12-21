local PROJECT_NAME = path.basename(os.projectdir())

add_rules("mode.debug", "mode.release")

set_project(PROJECT_NAME)

add_requires("pcre2")

target("cli")
    set_basename(PROJECT_NAME)
    set_kind("binary")
    set_languages("c11")
    set_version("2.0.0", {build = "%Y%m%d%H%M"})

    if has_config("musl") then
        add_cflags("-static", "-fuse-ld=musl")
        add_ldflags("-static", "-fuse-ld=musl")
        add_cxflags("-static", "-fuse-ld=musl")

    add_packages("pcre2")
    add_files("src/*.c", "src/**/*.c")

    on_package(function (target)
        if is_mode("release") then
            import("scripts.package")

            package.package_release(target)
        end
    end)
