#include <iostream> // cin, cout, string
#include <new>
#include <string>
using namespace std;

int main(int argc, const char * argv[]) {
    int A[10];
    for (int i=0; i<10; i++) {
        A[i] = rand() % 100;
    }
    // sort an array
    int temp;
    for (int i=0; i<10; i++) {
        for (int j=0; j<10-i; j++) {
            if (A[j] > A[j+1]) {
                // swap two values
                temp = A[j];
                A[j] = A[j+1];
                A[j+1] = temp;
            } // the last index will have the largest value of an array
        }
    }
    // another version of Bubble sort
    /*for (int i=0; i<10; i++) {
        for (int j=9; j>i; j--) {
            if (A[j] < A[i]) {
                temp = A[j]; // the smaller one into temporary value
                A[j] = A[i];
                A[i] = temp;
            }
        }
    }*/
    // print the result
    for (int i=0; i<10; i++) {
        cout << A[i] << " ";
    }
    
    return 0;
}
