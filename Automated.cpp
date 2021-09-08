#include <iostream> // cin, cout
#include <new>
#include <string>
#include <math.h> // sqrt, pow
using namespace std;

double square(double x, double y) {
    return sqrt(pow(x, 2) + pow(y, 2));
}

void printExplanation() {
    cout << "You are stepping into the world of C++ \n"
         << "Do not be afraid of taking challenges \n"
         << endl;
}

void multiplyByTwo(int& m) {
    m *= 2;
}


int main(int argc, const char * argv[]) {
    printExplanation();
    double x, y, res;
    char ans;
    cout << "Do you want to continue? " << endl;
    cin >> ans;
    while (ans != 'n') {
        cout << "Please enter x and y value: ";
        cin >> x >> y;
        if (x <= 0 || y <= 0) {
            cout << "This is invalid expression!" << endl;
        } else {
            res = square(x, y);
            cout << "The result is " << res << endl;
        }
        cout << "Do you want to continue? " << endl;
        cin >> ans;
        if (ans == 'n')     break;
    }
    return 0;
}
