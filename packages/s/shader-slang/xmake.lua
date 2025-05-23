package("shader-slang")
    set_homepage("https://github.com/shader-slang/slang")
    set_description("Making it easier to work with shaders")
    set_license("MIT")

    add_urls("https://github.com/shader-slang/slang.git", { submodules = false })

    add_versions("v2025.9.2", "27c6e9b01f7386263bde90e16812be46327015c2")

    add_patches("v2025.9.2", path.join(os.scriptdir(), "patches", "v2025.9.2", "1-glslang.patch"), "e21791079a1b4c785f3bc1158d3129f9a8f20d2d94c42b6bb854220871930d50")
    add_patches("v2025.9.2", path.join(os.scriptdir(), "patches", "v2025.9.2", "2-packages.patch"), "7d821317eeca38574de42aa347135f043230b0ae19e5edb792e53bb62d003b0b")

    add_configs("shared", { description = "Build shared library", default = true, type = "boolean", readonly = true })
    add_configs("embed_core_module", { description = "Build slang with an embedded version of the core module", default = true, type = "boolean" })
    add_configs("embed_core_module_source", { description = "Embed the core module source in the binary", default = false, type = "boolean" })
    add_configs("enable_dxil", { description = "Enable generating DXIL using DXC", default = false, type = "boolean" })
    add_configs("enable_asan", { description = "Enable ASAN (address sanitizer)", default = false, type = "boolean" })
    add_configs("enable_full_ir_validation", { description = "Enable full IR validation (SLOW!)", default = false, type = "boolean" })
    add_configs("enable_ir_break_alloc", { description = "IR BreakAlloc functionality for debugging", default = false, type = "boolean" })
    add_configs("enable_slangd", { description = "Enable language server target", default = false, type = "boolean" })
    add_configs("enable_slangc", { description = "Enable standalone compiler target", default = false, type = "boolean" })
    add_configs("enable_slangi", { description = "Enable Slang interpreter target", default = false, type = "boolean" })
    add_configs("enable_slangrt", { description = "Enable runtime target", default = false, type = "boolean" })
    add_configs("enable_slang_glslang", { description = "Enable glslang dependency and slang-glslang wrapper target", default = false, type = "boolean" })

    add_deps("cmake")
    add_deps("unordered_dense v4.5.0")
    add_deps("miniz 2.2.0")
    add_deps("lz4 v1.10.0")
    add_deps("spirv-headers 1.4.309+0")
    add_deps("spirv-tools 1.4.309+0")
    add_deps("glslang 1.4.309+0")

    on_install("windows|x64", "macosx", "linux|x86_64", function (package)
        io.replace("cmake/SlangTarget.cmake", [[set_property(TARGET ${target} PROPERTY SUFFIX ".dylib")]], "", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSLANG_LIB_TYPE=" .. (package:config("shared") and "SHARED" or "STATIC"))
        table.insert(configs, "-DSLANG_EMBED_CORE_MODULE=" .. (package:config("embed_core_module") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_EMBED_CORE_MODULE_SOURCE=" .. (package:config("embed_core_module_source") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_DXIL=" .. (package:config("enable_dxil") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_ASAN=" .. (package:config("enable_asan") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_FULL_IR_VALIDATION=" .. (package:config("enable_full_ir_validation") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_IR_BREAK_ALLOC=" .. (package:config("enable_ir_break_alloc") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_SLANGD=" .. (package:config("enable_slangd") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_SLANGC=" .. (package:config("enable_slangc") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_SLANGI=" .. (package:config("enable_slangi") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_SLANGRT=" .. (package:config("enable_slangrt") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_SLANG_GLSLANG=" .. (package:config("enable_slang_glslang") and "ON" or "OFF"))

        table.insert(configs, "-DSLANG_USE_SYSTEM_MINIZ=ON")
        table.insert(configs, "-DSLANG_USE_SYSTEM_LZ4=ON")
        table.insert(configs, "-DSLANG_USE_SYSTEM_VULKAN_HEADERS=ON")
        table.insert(configs, "-DSLANG_USE_SYSTEM_SPIRV_HEADERS=ON")
        table.insert(configs, "-DSLANG_SPIRV_HEADERS_INCLUDE_DIR=" .. package:dep("spirv-headers"):installdir())
        table.insert(configs, "-DSLANG_USE_SYSTEM_UNORDERED_DENSE=ON")
        table.insert(configs, "-DSLANG_USE_SYSTEM_SPIRV_TOOLS=ON")
        table.insert(configs, "-DSLANG_USE_SYSTEM_GLSLANG=ON")

        table.insert(configs, "-DSLANG_ENABLE_GFX=OFF")
        table.insert(configs, "-DSLANG_ENABLE_TESTS=OFF")
        table.insert(configs, "-DSLANG_ENABLE_EXAMPLES=OFF")
        table.insert(configs, "-DSLANG_SLANG_LLVM_FLAVOR=DISABLE")
        table.insert(configs, "-DSLANG_ENABLE_CUDA=OFF")
        table.insert(configs, "-DSLANG_ENABLE_OPTIX=OFF")
        table.insert(configs, "-DSLANG_ENABLE_NVAPI=OFF")
        table.insert(configs, "-DSLANG_ENABLE_AFTERMATH=OFF")
        table.insert(configs, "-DSLANG_ENABLE_XLIB=OFF")
        table.insert(configs, "-DSLANG_ENABLE_DX_ON_VK=OFF")
        table.insert(configs, "-DSLANG_ENABLE_SLANG_RHI=OFF")

        local packagedeps = {}
        table.insert(packagedeps, "unordered_dense")
        table.insert(packagedeps, "miniz")
        table.insert(packagedeps, "lz4")
        table.insert(packagedeps, "spirv-headers")
        table.insert(packagedeps, "spirv-tools")
        table.insert(packagedeps, "glslang")

        import("package.tools.cmake").install(package, configs, { packagedeps = packagedeps })
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({ test = [[
            #include <slang-com-ptr.h>
            #include <slang.h>

            void test() {
                Slang::ComPtr<slang::IGlobalSession> global_session;
                slang::createGlobalSession(global_session.writeRef());
            }
        ]] }, {configs = {languages = "c++17"}}))
    end)
package_end()

