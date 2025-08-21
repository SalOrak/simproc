const std = @import("std");

const Cpu = struct {
    // Frequency. How many cycles per second executes.
    clock: u64,
    // Number of cores available to run tasks.
    n_cores: u8, 
};

pub fn min(a: std.ArrayList) u16 {
    var minimum: f64 = a[0]; 
    var i: u16 = undefined; 
    for (0..a) |j| {
        if (minimum > a[j]){
            i = j;
            minimum = a[j];
        }
    } 
    return i;
} 

pub fn simulate(cpu: Cpu , tasks: []Task) f64 {
    // const n_ins: f64 = blk: {
    //     var total: u64 = 0;
    //     for (tasks) |task| { total += task.n_ins;}
    //     break :blk @as(f64, @floatFromInt(total));
    // };
    //
    const allocator = std.heap.page_allocator; 
    const total_time: f64 = 0.0;
    var cores = std.ArrayList(f64).init(allocator);
    var times_per_tasks = std.ArrayList(f64).init(allocator);
    
    for (tasks) |task| {
        times_per_tasks.append(@as(f64, @floatFromInt(task.n_ins) / @floatFromInt(cpu.clock)));
    }
    
    const items = @min(times_per_tasks.len, cpu.n_cores);
    for (0..items) |i| {
        cores.append(times_per_task[i]);
    }

    while(min < times_per_tasks.len) {
        const min_index = min(times_per_tasks);
        total_time += times_per_tasks[min_index];
        items += 1;
        times_per_tasks[min_index] = times_per_tasks[min_index];
    }

    return total_time; 
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
