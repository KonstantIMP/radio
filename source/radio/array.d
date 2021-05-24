// Define array module
module radio.array;

// Import algorithms
import std.algorithm;

// Get the smallest array's element
float min(float [] arr) {
    if (arr.length == 0) return 0.0;
    float result = arr[0];

    foreach(i; arr) {
        if (i < result) result = i;
    }

    return result;
}

// Get the bigest array's element
float max(float [] arr) {
    if (arr.length == 0) return 0.0;
    float result = arr[0];

    foreach(i; arr) {
        if (i > result) result = i;
    }

    return result;
}
