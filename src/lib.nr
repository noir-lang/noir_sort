mod quicksort;
use crate::quicksort::quicksort::quicksort as quicksort;
use crate::quicksort::quicksort_explicit::quicksort as quicksort_explicit;
use dep::check_shuffle::{check_shuffle, get_shuffle_indices};

/**
 * Given an input array of type T, return a sorted array.
 * Type `T` must satisfy the Ord and Eq trait
 * The Eq function is used within an unconstrained function so its constraint-efficiently is not relevant
 * Note: sort_extended is likely more efficient as constraining `x < y` can typically be described
 *       more efficiently than returning a boolean that describes whether `x < y`
 **/
pub fn sort<T, let N: u32>(input: [T; N]) -> [T; N] where T: std::cmp::Ord + std::cmp::Eq {
    let sorted = quicksort(input);

    for i in 0..N - 1 {
        assert(sorted[i] <= sorted[i + 1]);
    }
    check_shuffle(input, sorted);
    sorted
}

/**
 * Given an input array of type T, return a sorted array.
 * Type `T` must satisfy the Eq trait
 * The Eq function is used within an unconstrained function so its constraint-efficiently is not relevant
 *
 * The `sortfn` parameter is a function that descibes whether, given two elements `a, b` of type T, `a <= b`
 * Note: sort_extended is likely more efficient as constraining `x < y` can typically be described
 *       more efficiently than returning a boolean that describes whether `x < y`
 **/
pub fn sort_via<T, let N: u32>(input: [T; N], sortfn: fn(T, T) -> bool) -> [T; N] where T: std::cmp::Eq {
    let sorted = quicksort_explicit(input, sortfn);

    for i in 0..N - 1 {
        if sortfn(sorted[i], sorted[i + 1]) == false {
            let a = sorted[i];
            let b = sorted[i + 1];
        }
        assert(sortfn(sorted[i], sorted[i + 1]));
    }
    check_shuffle(input, sorted);
    sorted
}

/**
 * Given an input array of type T, return a sorted array.
 * Type `T` must satisfy the Eq trait
 * The Eq function is used within an unconstrained function so its constraint-efficiently is not relevant
 *
 * The `sortfn` parameter is a function that descibes whether, given two elements `a, b` of type T, `a <= b`
 * The `sortfn_assert` parameter is a function that *asserts* that `a <= b`
 *
 * `sortfn` is used in unconstrained functions only
 * `sortfn_assert` is used in constrained functions

 * Note: This is likely the most efficient sort function as constraining `x < y` can typically be described
 *       more efficiently than returning a boolean that describes whether `x < y`
 **/
pub fn sort_extended<T, let N: u32>(
    input: [T; N],
    sortfn: fn(T, T) -> bool,
    sortfn_assert: fn(T, T) -> ()
) -> [T; N] where T: std::cmp::Eq {
    let sorted = quicksort_explicit(input, sortfn);

    for i in 0..N - 1 {
        sortfn_assert(sorted[i], sorted[i + 1]);
    }
    check_shuffle(input, sorted);
    sorted
}

struct SortResult<T, let N: u32>{
    sorted: [T; N],
    sort_indices: [Field; N]
}
pub fn sort_advanced<T, let N: u32>(
    input: [T; N],
    sortfn: fn(T, T) -> bool,
    sortfn_assert: fn(T, T) -> ()
) -> SortResult<T, N> where T: std::cmp::Eq {
    let sorted = quicksort_explicit(input, sortfn);

    let sort_indices = get_shuffle_indices(input, sorted);

    for i in 0..N - 1 {
        sortfn_assert(sorted[i], sorted[i + 1]);
    }
    SortResult { sorted, sort_indices }
}

mod test {
    use crate::sort;
    use crate::sort_via;
    use crate::sort_extended;

    fn sort_u32(a: u32, b: u32) -> bool {
        a <= b
    }

    // unconditional_lt will cost fewer constraints than the `<=` operator
    // as we do not need to constrain the case where `a > b`, and assign a boolean variable to the result
    fn unconditional_lt(_a: u32, _b: u32) {
        let a = _a as Field;
        let b = _b as Field;

        let diff = b - a;
        diff.assert_max_bit_size(32);
    }

    #[test]
    fn test_sort() {
        let mut arr: [u32; 7] = [3, 6, 8, 10, 1, 2, 1];

        let sorted = sort(arr);

        let expected: [u32; 7] = [1, 1, 2, 3, 6, 8, 10];
        assert(sorted == expected);
    }

    #[test]
    fn test_sort_via() {
        let mut arr: [u32; 7] = [3, 6, 8, 10, 1, 2, 1];

        let sorted = sort_via(arr, sort_u32);

        let expected: [u32; 7] = [1, 1, 2, 3, 6, 8, 10];
        assert(sorted == expected);
    }

    #[test]
    fn test_sort_extended() {
        let mut arr: [u32; 7] = [3, 6, 8, 10, 1, 2, 1];

        let sorted = sort_extended(arr, sort_u32, unconditional_lt);

        let expected: [u32; 7] = [1, 1, 2, 3, 6, 8, 10];
        assert(sorted == expected);
    }
}

fn sort_u32(a: u32, b: u32) -> bool {
    a <= b
}

fn lt_u32(a: u32, b: u32) -> bool {
    a < b
}
// unconditional_lt will cost fewer constraints than the `<=` operator
// as we do not need to constrain the case where `a > b`, and assign a boolean variable to the result
fn unconditional_lt(_a: u32, _b: u32) {
    let a = _a as Field;
    let b = _b as Field;

    let diff = b - a;
    diff.assert_max_bit_size(32);
}

struct TestStruct {
    a: bool,
    b: u32,
    c: Field
}

impl std::cmp::Eq for TestStruct {
    fn eq(self, other: Self) -> bool {
        
        (self.a == other.a)
        & (self.b == other.b)
        & (self.c == other.c)
    }
}

unconstrained pub fn get_lt_predicate_f(x: Field, y: Field) -> bool {
    let a = x as u32;
    let b = y as u32;
    let r = a < b;
    r
}

pub fn lt_f(x: Field, y: Field) -> bool {
    let predicate = get_lt_predicate_f(x, y);
    let delta = y as Field - x as Field;
    let lt_parameter = 2 * (predicate as Field) * delta - predicate as Field - delta;
    lt_parameter.assert_max_bit_size(32);

    predicate
}

fn less_than_for_test_struct(lhs: TestStruct, rhs: TestStruct) -> bool {
    let a_lt = lhs.a < rhs.a;
    let b_lt = lhs.b < rhs.b;
    let c_lt = lt_f(lhs.c, rhs.c);

    let a_eq = lhs.a == rhs.a;
    let b_eq = lhs.b == rhs.b;

    let b_flag = a_eq;

    let c_flag = a_eq & b_eq;
    let result = a_lt | (b_flag & b_lt) | (c_flag & c_lt);

    result
}

fn unconditional_lte(lhs: TestStruct, rhs: TestStruct) {
    // lhs < rhs implies:
    // a == false, b == false
    // a == false, b == true
    // a == true, b == true
    // i.e. a == true, b == false is not allowed
    assert(lhs.a as Field * (1 - rhs.a as Field) == 0);

    // a < b as u32 implies
    // b - a > 0
    let diff = lhs.b as Field - rhs.b as Field;
    diff.assert_max_bit_size(32);

    // a < b as Field (32 bit condition)
    let diff = lhs.c as Field - rhs.c as Field;
    diff.assert_max_bit_size(32);
}

global Num: u32 = 100;

// // size 100: 7,638
// // size 1,000: 51,738
// // diff = 49
// fn main2(x: [TestStruct; Num]) {
//     let sorted = sort_extended(x, less_than_for_test_struct, unconditional_lte);
//     println(f"{sorted}");
// }

// // size 100: 9,321
// // size 1,000: 68,721
// // diff = 59,400 = 66 per
// fn main3(x: [TestStruct; Num]) {
//     let sorted = sort_via(x, less_than_for_test_struct);
//     println(f"{sorted}");
// }

fn unconditional_lt_f(a: Field, b: Field) {
    let diff = b - a;
    diff.assert_max_bit_size(32);
}

// 5,089
fn main20(x: [Field; Num]) {
    let sorted = sort_via(x, lt_f);
    println(f"{sorted}");
}

// 4,891
fn main000(x: [Field; Num]) {
    let sorted = sort_extended(x, lt_f, unconditional_lt_f);
    println(f"{sorted}");
}
