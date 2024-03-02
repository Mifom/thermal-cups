const std = @import("std");
const LazyPath = std.Build.LazyPath;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = std.builtin.OptimizeMode.ReleaseFast });
    const usePpdc = b.option(bool, "generate_ppd", "Use ppdc to generate ppds") orelse false;
    const newRaster = b.option(bool, "new_raster", "Use new raster") orelse false;

    const cflags = [_][]const u8{
        "-Wall",
        "-fPIE",
        "-fPIC",
    };

    const thermal = b.addExecutable(.{ .name = "thermal-cups", .optimize = optimize, .target = target });
    thermal.linkLibC();
    thermal.linkSystemLibrary("cups");

    thermal.addCSourceFiles(&.{"rastertozj.c"}, &cflags);
    if (newRaster) {
        thermal.defineCMacro("NEWRASTER", null);
    }

    b.installArtifact(thermal);

    if (usePpdc) {
        const ppd = LazyPath.relative("ppd");
        const ppdc = b.addSystemCommand(&.{"ppdc"});
        ppdc.setEnvironmentVariable("LANG", "c");
        ppdc.addArg("-d");
        ppdc.addDirectoryArg(ppd);
        ppdc.addFileArg(.{ .path = "zjdrv.drv" });

        const ppds = b.addInstallDirectory(.{ .source_dir = ppd, .install_dir = .prefix, .install_subdir = "ppd" });
        ppds.step.dependOn(&ppdc.step);
        b.getInstallStep().dependOn(&ppds.step);
        // for ([_][]const u8{ "zj58", "xp58", "tm20", "zj80" }) |ppd_name| {
        //     const path = b.fmt("ppd/{s}.ppd", .{ppd_name});
        //     const artifact = b.addInstallFileWithDir(.{ .path = path }, path);
        //     b.getInstallStep().dependOn(&artifact.step);
        // }

    } else {
        const artifact58 = b.addInstallFile(.{ .path = "zj58.ppd" }, "ppd/zj58.ppd");
        b.getInstallStep().dependOn(&artifact58.step);
        const artifact80 = b.addInstallFile(.{ .path = "zj80.ppd" }, "ppd/zj80.ppd");
        b.getInstallStep().dependOn(&artifact80.step);
    }
}
