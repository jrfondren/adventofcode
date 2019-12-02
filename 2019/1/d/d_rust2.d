import std;

void main() {
    int[] fuel_list = slurp!int("input.txt", "%d");
    double sum = 0.0;
    int n = 0;
    while (n < fuel_list.length) {
        auto tmp = (fuel_list[n++] / 3.0).floor - 2.0;
        sum += tmp;

        while (tmp > 5.0) {
            tmp = (tmp/3.0).floor - 2.0;
            sum += tmp;
        }
    }
    writeln(cast(int) sum);
}
