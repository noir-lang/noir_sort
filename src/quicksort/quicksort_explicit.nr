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

unconstrained fn quicksort_loop<T, let N: u32>(
    arr: &mut [T; N],
    low: u32,
    high: u32,
    sortfn: unconstrained fn(T, T) -> bool,
) {
    let mut low = low;
    let mut high = high;
    loop {
        // TODO cleanup
        println(("begin of loop", *arr, low, high));

        if low >= high {
            break;
        }
        let pivot_index = partition(arr, low, high, sortfn);
        if pivot_index > 0 {
            high = pivot_index - 1;
        }
        low = pivot_index + 1;

        // assert((begin_low == low) | (begin_high == high));

        // TODO cleanup
        println(("end of loop", *arr, low, high));
    }
}

pub unconstrained fn quicksort<T, let N: u32>(
    arr: [T; N],
    sortfn: unconstrained fn(T, T) -> bool,
) -> [T; N] {
    let mut arr: [T; N] = arr;
    if arr.len() <= 1 {} else {
        quicksort_loop(&mut arr, 0, arr.len() - 1, sortfn);
    }
    arr
}
