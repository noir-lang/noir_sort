# noir_sort

Efficiently sorts fixed-sized arrays.

## Noir version compatibility

This library is tested with all Noir stable releases from v0.36.0.

## Usage

1. Basic usage:

```
use dep::sort::sort;

fn foo(a: [u32; 100]) -> [u32; 100] {
    sort(a) // tadaa
}
```

2. Usage with a custom sort function

```
use dep::sort::sort_custom;

struct Entry {
    key: Field,
    value: u32
}
fn sort_entry(a: Entry, b: Entry) -> bool {
    a.value <= b.value
}

fn foo(a: [Entry; 100]) -> [Entry; 100] {
    sort_custom(a, sort_entry)
}
```

3. Usage with an _unconditional_ lte function

```
fn sort_u16(a: u16, b: u16) -> bool { a <= b }

fn unconditional_lte(a: u16, b: u16) {
    let diff = (b as Field - a as Field);
    diff.assert_max_bit_size(16);
}

fn foo(a: [u16; 100]) -> [u16; 100] {
    sort_extended(a, sort_u16, unconditional_lte)
}
```

## Comments

The `sort_extended` method is likely to be the most efficient method as asserting that `a <= b` costs fewer constraints than determining whether `a <= b` and assigning a bool to the outcome (e.g. for a `u16`, the `<=` operator needs to constrain the case where `a <= b` and `a > b` and then conditionally assign the return value to the correct case)

## Algorithm Description

The library executes, in an unconstrained function, a quicksort algorithm to determine the sorted array.

The library perform two constrained steps:

1. Validates the sorted array contains the same values as the unsorted array (using the `check_shuffle` library)
2. Validates that, for the sorted array, successive elements are not smaller than previous elements

The algorithm is highly optimized and the cost is _linear_ in the size of the array.
