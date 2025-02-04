pub trait Swap {
    fn swap(&mut self, i: u32, j: u32);
}

impl<T, let N: u32> Swap for [T; N] {
    fn swap(&mut self, i: u32, j: u32) {
        let temp = self[i];
        self[i] = self[j];
        self[j] = temp;
    }
}

unconstrained fn partition<T, let N: u32>(
    arr: &mut [T; N],
    low: u32,
    high: u32,
    sortfn: unconstrained fn(T, T) -> bool,
) -> u32 {
    let pivot = high;
    let mut i = low;
    for j in low..high {
        if (sortfn(arr[j], arr[pivot])) {
            arr.swap(i, j);
            i += 1;
        }
    }
    arr.swap(i, pivot);
    i
}

unconstrained fn quicksort_recursive<T, let N: u32>(
    arr: &mut [T; N],
    low: u32,
    high: u32,
    sortfn: unconstrained fn(T, T) -> bool,
) {
    if low < high {
        let pivot_index = partition(arr, low, high, sortfn);
        if pivot_index > 0 {
            // TODO cleanup
            println(("recursive (pivot_index > 0)", *arr, low, pivot_index - 1, pivot_index));
            quicksort_recursive(arr, low, pivot_index - 1, sortfn);
        }

        // TODO cleanup
        println(("recursive", *arr, pivot_index + 1, high, pivot_index));
        quicksort_recursive(arr, pivot_index + 1, high, sortfn);
    }
}

pub unconstrained fn quicksort<T, let N: u32>(
    _arr: [T; N],
    sortfn: unconstrained fn(T, T) -> bool,
) -> [T; N] {
    let mut arr: [T; N] = _arr;
    if arr.len() <= 1 {} else {
        quicksort_recursive(&mut arr, 0, arr.len() - 1, sortfn);
    }
    arr
}

