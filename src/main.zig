const std = @import("std");

const Cpu = struct {
    // Frequency. How many cycles per second executes.
    clock: u64,
    // Number of cores available to run tasks.
    n_cores: u8, 
};

pub fn min(array: std.ArrayList(f64)) usize {
    var minimum: f64 = std.math.inf(f64); 
    var i: usize = undefined; 
    for (0..array.items.len) |j| {
        if (minimum > array.items[j]){
            i = j;
            minimum = array.items[j];
        }
    } 
    return i;
} 

const talloc = std.testing.allocator;
const expect = std.testing.expect;
test {
    var array = std.ArrayList(f64).init(talloc);
    defer array.deinit();
    try array.append(2.0);
    try array.append(1.0);  
    try array.append(3.0);
     
    const result = min(array);
    std.debug.print("{d}\n", .{result});
    try expect(result == 1); 
}

pub fn substractToArrayList(array: *std.ArrayList(f64), x: f64) void {
    for (0..array.items.len) |i| { //dereferrence by itself?
        array.items[i] -= x;
    } 
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
    defer {
        cores.deinit();
        times_per_tasks.deinit();
    } 

    const clock: f64 = @as(f64, @floatFromInt(cpu.clock));

    for (tasks) |task| {
        const nins: f64 = @as(f64, @floatFromInt(task.n_ins));
        try times_per_tasks.append(nins/clock);
    }
    
    // spots as in free spaces to fill them with tasks
    const spots = @min(times_per_tasks.items.len, cpu.n_cores);
    std.debug.print("{d}\n", .{spots});
    for (0..spots) |_| {
        const task_time = times_per_tasks.pop() orelse unreachable;
        try cores.append(task_time);
    }

    std.debug.print("{any}\n", .{cores});
    
    var counter: u16 = 0;
    while(counter < tasks.len) {
        std.debug.print("Iteration: {any}\n", .{cores.items}); const smaller_task_index = min(cores);
        std.debug.print("{}\n", .{cores.items[smaller_task_index]});
        const time = cores.swapRemove(smaller_task_index);
        total_time += time; 
        substractToArrayList(&cores, time); 
        counter += 1;
        const next_item_opt = times_per_tasks.pop() orelse continue;
        try cores.append(next_item_opt);
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

    const t3: Task = Task {
        .n_ins = 3000,
    };
    
    var tasks = [_]Task{ 
        t,
        t2,
        t3,
    };


    std.debug.print("Result {!d}\n", .{simulate(cpu, &tasks)});

}
