const std = @import("std");

const Cpu = struct {
    // Frequency. How many cycles per second executes.
    clock: u64,
    // Number of cores available to run tasks.
    n_cores: u8, 
};

pub fn simulate(cpu: Cpu , tasks: []Task) f64 {

    const n_ins: f64 = blk: {
        var total: u64 = 0;
        for (tasks) |task| { total += task.n_ins;}
        break :blk @as(f64, @floatFromInt(total));
    };
    
    
    var time: f64 = 0.0;
    while (true) {

    }

    // const n_ins: f64 = @floatFromInt(task.n_ins);
    const ins_per_sec: f64 = @floatFromInt(cpu.clock * cpu.n_cores);

    return n_ins / ins_per_sec;
}

const Task = struct {
    // Number of atomic instructions required per task.
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

    const t2 : Task = Task {
        .n_ins = 3000,
    };

    var tasks = [_]Task{ 
        t,
        t2,
    };


    std.debug.print("Result {d}\n", .{simulate(cpu, &tasks)});

}
