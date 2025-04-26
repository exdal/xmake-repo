package("implot")
    set_homepage("https://github.com/epezent/implot")
    set_description("Immediate Mode Plotting")
    set_license("MIT")

    add_urls("https://github.com/epezent/implot.git")

    add_versions("v1.91.8-docking", "3da8bd34299965d3b0ab124df743fe3e076fa222")

    add_configs("wchar32", {description = "Support ImWchar32", type = "boolean", default = false})

    on_load(function (package)
        local v = package:version()
        package:add("deps", "imgui " .. v)
    end)

    on_install("windows", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        local imgui = package:dep("imgui")
        local configs = imgui:requireinfo().configs
        configs.wchar32 = package:config("wchar32")

        if configs then
            configs = string.serialize(configs, {strip = true, indent = false})
        end

        local xmake_lua = ([[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")

            add_requires("imgui %s", {configs = %s})

            target("implot")
                set_kind("static")
                add_files("*.cpp|implot_demo.cpp")
                add_headerfiles("*.h")
                add_packages("imgui")
        ]]):format(imgui:version_str(), configs)
        io.writefile("xmake.lua", xmake_lua)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <implot.h>
            void test() {
                ImPlot::CreateContext();
                ImPlot::DestroyContext();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
