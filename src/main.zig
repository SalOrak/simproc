const std = @import("std");

const Cpu = struct {
    // Frequency. How many cycles per second executes.
    clock: u64,
    // Number of cores available to run tasks.
    n_cores: u8, 
};

pub fn min(array: std.ArrayList(f64)) usize {
    var minimum: f64 = array.items[0]; 
    var i: usize = undefined; 
    for (0..array.items.len) |j| {
        if (minimum > array.items[j]){
            i = j;
            minimum = array.items[j];
        }
    } 
    return i;
} 

pub fn simulate(cpu: Cpu , tasks: []Task) !f64 {
    // const n_ins: f64 = blk: {
    //     var total: u64 = 0;
    //     for (tasks) |task| { total += task.n_ins;}
    //     break :blk @as(f64, @floatFromInt(total));
    // };
    //
    const allocator = std.heap.page_allocator; 
    var total_time: f64 = 0.0;
    var cores = std.ArrayList(f64).init(allocator);
    var times_per_tasks = std.ArrayList(f64).init(allocator);
    
    for (tasks) |task| {
        const nins: f64 = @as(f64, @floatFromInt(task.n_ins));
        const clock: f64 = @as(f64, @floatFromInt(cpu.clock));

        try times_per_tasks.append(nins/clock);
    }
    
    // spots as in free spaces to fill them with tasks
    var spots = @min(times_per_tasks.items.len, cpu.n_cores);
    for (0..spots) |i| {
        try cores.append(times_per_tasks.items[i]);
    }

    while(spots < times_per_tasks.items.len) {
        const smaller_task_index = min(cores);
        total_time += cores.items[smaller_task_index];
        spots += 1;
        cores.items[smaller_task_index] = times_per_tasks.items[smaller_task_index];
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


    std.debug.print("Result {!d}\n", .{simulate(cpu, &tasks)});

}
