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

unconstrained fn partition<T, let N: u32>(arr: &mut [T; N], low: u32, high: u32) -> u32
where
    T: std::cmp::Ord,
{
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

unconstrained fn quicksort_loop<T, let N: u32>(arr: &mut [T; N], low: u32, high: u32)
where
    T: std::cmp::Ord,
{
    let mut stack: [(u32, u32)] = &[(low, high)];
    loop {
        if stack.len() == 0 {
            break;
        }

        let (new_stack, (new_low, new_high)) = stack.pop_back();
        stack = new_stack;

        if new_high < new_low + 1 {
            continue;
        }

        let pivot_index = partition(arr, new_low, new_high);
        stack = stack.push_back((pivot_index + 1, new_high));
        if 0 < pivot_index {
            stack = stack.push_back((new_low, pivot_index - 1));
        }
    }
}

pub unconstrained fn quicksort<T, let N: u32>(_arr: [T; N]) -> [T; N]
where
    T: std::cmp::Ord,
{
    let mut arr: [T; N] = _arr;
    if arr.len() <= 1 {} else {
        quicksort_loop(&mut arr, 0, arr.len() - 1);
    }
    arr
}

