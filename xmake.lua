local PROJECT_NAME = path.basename(os.projectdir())

add_rules("mode.debug", "mode.release")

set_project(PROJECT_NAME)

-- 针对 musl 平台配置 pcre2 静态链接
add_requires("pcre2", {
    config = {
        shared = not (is_plat("linux") and get_config("toolchain") == "musl")
    }
})

target("cli")
    set_basename(PROJECT_NAME)
    set_kind("binary")
    set_languages("c11")
    set_version("2.0.0", {build = "%Y%m%d%H%M"})

    add_packages("pcre2")
    add_files("src/*.c", "src/**/*.c")

    -- musl 平台静态编译配置
    if is_plat("linux") and get_config("toolchain") == "musl" then
        set_toolchains("musl")
        add_cflags("-static")
        add_ldflags("-static")
        set_targetdir("build/musl")
    end

    on_package(function (target)
        if is_mode("release") then
            import("scripts.package")
            package.package_release(target)
        end
    end)