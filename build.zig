const std = @import("std");

pub fn build(b: *std.Build) void {
    const os = b.addExecutable(.{
        .name = "os.elf",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .x86,
            .os_tag = .freestanding,
        }),
    });
    os.setLinkerScriptPath(b.path("./linker.ld"));
    b.installArtifact(os);

    const run_cmd = b.addSystemCommand(&.{
        "qemu-system-x86_64",
        "-kernel",
        "zig-out/bin/os.elf",
        "-display",
        "gtk,zoom-to-fit=on",
    });
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the os");
    run_step.dependOn(&run_cmd.step);
}
