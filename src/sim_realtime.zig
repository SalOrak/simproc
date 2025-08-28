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

//duration is in ms
pub fn simulate(cpu: Cpu, duration: f64, workload: std.ArrayList(RealtimeTask)) !f64 {
    const allocator = std.heap.page_allocator; 
    var elapsed_time: f64 = 0.0;

    var cores = std.ArrayList(f64).init(allocator);

    defer {
        cores.deinit();
    } 
    
    const clock: f64 = @as(f64, @floatFromInt(cpu.clock));

    var now: f64 = 0;
    var n_cpu_tasks: @FieldType(Cpu, "n_cores") = 0;

    // Between idx and idx_last_processed_task are the tasks available to be processed by the CPU.
    var idx : u32 = 0; // Last available tasks representation in workload list index
    var idx_last_processed_task: u32 = 0; // Last processed tasks (executed in cpu) index

    while(now <= duration) {
        // find first non-available task
        while (true) {
            const task = workload.items[idx];
            if (task.arrival_time < now ) {
                idx += 1;
            } else {
                break;
            }
        }

        if (idx == idx_last_processed_task) {
            idx += 1;
            idx = @min(idx, workload.items.len - 1);
            now += workload.items[idx].arrival_time;
            continue;
        }

        if (n_cpu_tasks != cpu.n_cores) {
            const free_spots = cpu.n_cores - n_cpu_tasks; // how many cores are free
            const num_available_tasks = idx - idx_last_processed_task; //how many tasks are enqueued
            const tasks_into_cpu = @min(free_spots, num_available_tasks);
            
            for (0..tasks_into_cpu + 1) |i| {
                const current_task = workload.items[idx_last_processed_task + i];
                const nins: f64 = @as(f64, @floatFromInt(current_task.n_ins));
                const task_duration: f64 = nins/clock;
                try cores.append(task_duration);
            }
            idx_last_processed_task += tasks_into_cpu;
            n_cpu_tasks += tasks_into_cpu;
        }

        if (n_cpu_tasks == 0) {continue;}
        
        const smaller_task_index = min(cores);
        const time = cores.swapRemove(smaller_task_index);
        elapsed_time += time; 
        now += time;
        substractToArrayList(&cores, time);
        n_cpu_tasks -= 1;
    }


    return elapsed_time; 
}

test {
    
    const cpu: Cpu = Cpu {
        .n_cores = 2,
        .clock = 300,
    };
    
    {
        var tasks = std.ArrayList(RealtimeTask).init(talloc);  
        defer tasks.deinit();

        try tasks.append(RealtimeTask{.n_ins = 300, .arrival_time = 1});
        try tasks.append(RealtimeTask{.n_ins = 300, .arrival_time = 1});

        const result = try simulate(cpu, 5, tasks);
        const expected_result = 1;
        std.debug.print("Result {}\n", .{result});
        try expect(result == expected_result);
    }

    {
        var tasks = std.ArrayList(RealtimeTask).init(talloc);  
        defer tasks.deinit();
        try tasks.append(RealtimeTask{.n_ins = 300, .arrival_time = 1});
        try tasks.append(RealtimeTask{.n_ins = 600, .arrival_time = 1});

        const result = try simulate(cpu, 5, tasks);
        const expected_result = 2;
        std.debug.print("Result {}\n", .{result});
        try expect(result == expected_result);
    }
    {
        var tasks = std.ArrayList(RealtimeTask).init(talloc);  
        defer tasks.deinit();
        try tasks.append(RealtimeTask{.n_ins = 300, .arrival_time = 1});
        try tasks.append(RealtimeTask{.n_ins = 600, .arrival_time = 2});

        const result = try simulate(cpu, 5, tasks);
        const expected_result = 3;
        std.debug.print("Result {}\n", .{result});
        try expect(result == expected_result);
    }
}

const RealtimeTask = struct {
    // Number of atomic instructions required per task.
    n_ins: u64,
    arrival_time: f64,
};

const State = enum {generate, nothing};

fn generateWorkloadWithinTimeframe(comptime duration: f64, allocator: std.mem.Allocator) !std.ArrayList(RealtimeTask) {
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    
    var tasks = std.ArrayList(RealtimeTask).init(allocator);

    var prev_state = State.nothing;
    var actual_state = State.nothing;

    var i: f64 = 1;
    while (i < duration) : (i += 1) {
        if (prev_state == State.nothing) {
            const p = rand.float(f32);
            // workload starts
            if (p < 0.8) {
                actual_state = State.generate; 
            }
        } else {
            const p = rand.float(f32);
            if (p >= 0.9) {
                // workload stops
                actual_state = State.nothing;
            }
        }
     
        if (actual_state == State.generate) {
            const ops = rand.intRangeAtMost(@FieldType(RealtimeTask, "n_ins"), 100, 1000);
            try tasks.append(RealtimeTask{.n_ins = ops, .arrival_time = i});
        }

        prev_state = actual_state;
    }

    return tasks; 
} 

pub fn main() !void {
    const cpu: Cpu = Cpu {
        .n_cores = 2,
        .clock = 300,
    };
    
    const allocator = std.heap.page_allocator;
    const duration = 5;
    //var tasks = try generateWorkload(8);
    var tasks = try generateWorkloadWithinTimeframe(duration, allocator);
    defer tasks.deinit();

    std.debug.print("Duration {}\n", .{duration});
    std.debug.print("Tasks {any}\n", .{tasks});

    std.debug.print("Result {!d}\n", .{simulate(cpu, duration, tasks)});
}
