package("fmtlog-lr")
    set_homepage("https://github.com/MengRao/fmtlog")
    set_description("fmtlog is a performant fmtlib-style logging library with latency in nanoseconds.")
    set_license("MIT")

    add_urls("https://github.com/MengRao/fmtlog.git", {submodules = false})

    add_versions("v2.3.0", "769dee37a6375e2c4784c936c7191aaa755e669ef9ed311c412153305878ba56")

    add_configs("fmt_version", { description = "fmtlib version", default = nil, type = "string" })

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        package:add("deps", "fmt" .. ((" " .. package:config("fmt_version")) or ""), {configs = {header_only = true}})
    end)

    on_install("linux", "macosx", "windows|!arm64", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(fmt)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(bench)", "", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))

        local opt = {}
        opt.packagedeps = "fmt"
        if package:has_tool("cxx", "cl") and package:dep("fmt"):config("unicode") then
            opt.cxflags = "/utf-8"
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"),  "*.a"))
        else
            os.tryrm(path.join(package:installdir("lib"),  "*.dll"))
            os.tryrm(path.join(package:installdir("lib"),  "*.dylib"))
            os.tryrm(path.join(package:installdir("lib"),  "*.so"))
        end
        os.cp("*.h", package:installdir("include/fmtlog"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                logi("A info msg");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "fmtlog/fmtlog.h"}))
    end)
