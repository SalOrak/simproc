pub fn main() !void {

    const vec_len = 4;
    var vec = @Vector(vec_len, i32){ 1, 5 ,3 ,4};
    vec[0] = 5;

    const arr: [vec_len]i32 = vec;


    print("Vector: {any}\n", .{vec});
    print("Array : {any}\n", .{arr});
    print("Minues vec: {any}\n", .{minusVec(i32, vec_len, &arr)});
    // print("Vector  - 1: {any}\n", .{minusMinVec(vec, vec_len)});


}


fn minusMinVec(vec: @Vector(4, i32) , comptime vec_len: u32 ) @Vector(4, i32){
    const min = @reduce(.Min, vec);
    const min_vec = @as(@Vector(vec_len, i32), @splat(min));
    return vec - min_vec; 
}

fn minusVec(comptime T: type, comptime vec_len: u32, arr: *const [vec_len]T) [vec_len]T {
    const vec : @Vector(vec_len, T) = arr.*;
    const min = @reduce(.Min, vec);
    const min_vec = @as(@Vector(vec_len, T), @splat(min));
    const result = vec - min_vec;
    const result_array : [vec_len]T = result;
    return result_array;
}

// fn sumVector(vec: @Vector(4, i32)) @Vector(@typeInfo(@TypeOf(vec)).vector.len, @typeInfo(@TypeOf(vec)).vector.child) {
//     return vec;
// }
