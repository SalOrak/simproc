const std = @import("std");

const Cpu = struct {
    const Self = @This();
    // Frequency. How many cycles per second executes.
    clock: u64,
    // Number of cores available to run tasks.
    n_cores: u8, 

    pub fn simulate(self: *const Self, task: Task) f64 {

        const n_ins: f64 = @floatFromInt(task.n_ins);
        const ins_per_sec: f64 = @floatFromInt(self.clock * self.n_cores);

        return n_ins / ins_per_sec;
    }
};

const Task = struct {
    // Number of instructions required per task.
    n_ins: u64,
};

pub fn main() !void {
    const cpu: Cpu = Cpu {
        .n_cores = 2,
        .clock = 300,
    };

    const t : Task = Task {
        .n_ins = 300,
    };

    std.debug.print("Result {d}\n", .{cpu.simulate(t)});

}
