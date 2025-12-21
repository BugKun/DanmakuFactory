local PROJECT_NAME = path.basename(os.projectdir())

add_rules("mode.debug", "mode.release")

set_project(PROJECT_NAME)

-- 为musl配置静态依赖
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

    -- musl静态编译配置
    if is_plat("linux") and get_config("toolchain") == "musl" then
        -- 手动指定musl工具链参数
        set_toolchains("gcc")  -- 使用gcc兼容模式
        add_cflags("-static", "-fPIC")
        add_ldflags("-static", "-L/usr/lib/musl/lib")
        add_linkdirs("/usr/lib/musl")
        set_targetdir("build/musl")
    end

    on_package(function (target)
        if is_mode("release") then
            import("scripts.package")
            package.package_release(target)
        end
    end)