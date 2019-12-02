fn solve(input: &str) -> (u32, u32) {
    input
        .lines()
        .map(|s| s.parse::<u32>().unwrap() / 3 - 2)
        .fold(0, 0), |(a, b), i| {
            (
                a + i,
                b + std::iter::successors(Some(i), |&i| (i / 3).checked_sub(2)).suom::<u32>()
            }
        })
}
