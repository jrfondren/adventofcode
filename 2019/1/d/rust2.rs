use std::fs::File;
use std::io::prelude::*;

fn main() {
    
    let mut file = File::open("input")
        .expect("unable to open file");

    let mut contents = String::new();
    
    file.read_to_string(&mut contents)
        .expect("unable to read to string");

    let mut sum = 0.0;
    let mut n = 0;
    let mut tmp;
    let fuel_list: Vec<f32> = contents.split_whitespace().map(|s| s.parse().unwrap()).collect::<Vec<_>>();
    
    while n < fuel_list.len() {

        tmp = (fuel_list[n] / 3.0).floor() - 2.0;
        sum += tmp;

        while tmp > 5.0 {
            tmp = (tmp/3.0).floor() - 2.0;
            sum += tmp
        }
        n+=1;
    }

    println!("{}", sum);
}
