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
        try times_per_tasks.insert(0, nins/clock);
    }
    
    // spots as in free spaces to fill them with tasks
    const spots = @min(times_per_tasks.items.len, cpu.n_cores);
    for (0..spots) |_| {
        const task_time = times_per_tasks.pop() orelse break;
        try cores.append(task_time);
    }
    
    var counter: u16 = 0;
    while(counter < tasks.len) {
        const smaller_task_index = min(cores);
        const time = cores.swapRemove(smaller_task_index);
        total_time += time; 
        counter += 1;
        substractToArrayList(&cores, time); 
        const next_item_opt = times_per_tasks.pop() orelse continue;
        try cores.append(next_item_opt);
    }

    return total_time; 
}

const Task = struct {
    // Number of atomic instructions required per task.
    n_ins: u64,
};



fn make_task(n_ins: u64) Task{
    return Task {
        .n_ins = n_ins,
    };
}


pub fn main() !void {
    const cpu: Cpu = Cpu {
        .n_cores = 2,
        .clock = 300,
    };

    var tasks = comptime [_]Task{ 
        make_task(300),
        make_task(200),
        make_task(3000),
        make_task(200),
        make_task(200),
    };

    std.debug.print("Result {!d}\n", .{simulate(cpu, &tasks)});
}
