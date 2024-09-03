trait Swap {
    fn swap(&mut self, i: u32, j: u32);
}

impl<T, let N: u32> Swap for [T; N] {
    fn swap(&mut self, i: u32, j: u32) {
        let temp = self[i];
        self[i] = self[j];
        self[j] = temp;
    }
}

unconstrained fn partition<T, let N: u32>(arr: &mut [T; N], low: u32, high: u32) -> u32 where T: std::cmp::Ord {
    let pivot = high;
    let mut i = low;
    for j in low..high {
        if (arr[j] < arr[pivot]) {
            arr.swap(i, j);
            i += 1;
        }
    }
    arr.swap(i, pivot);
    i
}

unconstrained fn quicksort_recursive<T, let N: u32>(arr: &mut [T; N], low: u32, high: u32) where T: std::cmp::Ord {
    if low < high {
        let pivot_index = partition(arr, low, high);
        if pivot_index > 0 {
            quicksort_recursive(arr, low, pivot_index - 1);
        }
        quicksort_recursive(arr, pivot_index + 1, high);
    }
}

unconstrained pub fn quicksort<T, let N: u32>(_arr: [T; N]) -> [T; N] where T: std::cmp::Ord {
    let mut arr: [T; N] = _arr;
    if arr.len() <= 1 {} else {
        quicksort_recursive(&mut arr, 0, arr.len() - 1);
    }
    arr
}

