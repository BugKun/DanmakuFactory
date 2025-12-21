local PROJECT_NAME = path.basename(os.projectdir())

-- 基础构建规则
add_rules("mode.debug", "mode.release")
set_project(PROJECT_NAME)

-- 依赖配置：musl 环境强制静态链接 pcre2
add_requires("pcre2", {
    config = {
        -- 检测是否使用 musl-gcc 编译器，若是则静态链接
        shared = not (get_config("cc") == "musl-gcc")
    }
})

-- 主编译目标
target("cli")
    set_basename(PROJECT_NAME)
    set_kind("binary")
    set_languages("c11")
    set_version("2.0.0", {build = "%Y%m%d%H%M"})

    -- 添加源码和依赖
    add_packages("pcre2")
    add_files("src/*.c", "src/**/*.c")

    -- Linux-musl 专属编译配置
    if get_config("cc") == "musl-gcc" then
        -- 使用 gcc 兼容模式（musl-gcc 是 gcc 封装）
        set_toolchains("gcc")
        -- 强制静态编译（musl 推荐静态链接，保证跨发行版兼容性）
        add_cflags("-static", "-fPIC", "-O3")
        add_cxxflags("-static", "-fPIC", "-O3")
        add_ldflags("-static", "-s")
        -- 指定 musl 库路径（Ubuntu 下默认路径）
        add_linkdirs("/usr/lib/x86_64-linux-musl")
        add_ldflags("-L/usr/lib/x86_64-linux-musl")
        -- 输出到专属目录，避免和 glibc 版本冲突
        set_targetdir("build/musl")
    end

    -- 打包逻辑
    on_package(function (target)
        if is_mode("release") then
            import("scripts.package")
            package.package_release(target)
        end
    end)

-- 防止 musl 编译时的链接冲突
on_load(function (target)
    if get_config("cc") == "musl-gcc" then
        -- 禁用动态链接相关选项
        target:set("rpath", nil)
        target:set("shared", false)
    end
end)