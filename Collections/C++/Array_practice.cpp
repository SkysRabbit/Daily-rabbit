#include <iostream> // cin, cout, string
#include <new>
#include <string>
using namespace std;

int main(int argc, const char * argv[]) {
    int size;
    cout << "Please enter the size of an array: ";
    cin >> size;
    if (size > 0) {
        int *A = new int[size];
        int *B = new int[size-2];
        
        for (int i=0; i<size; i++) {
            // assign value to each index of two arrays
            A[i] = i+1;
        }
        for (int j=0; j<size-2; j++) {
            B[j] = 2 * A[j+1];// from A[1] to A[size-2]
        }
        // print the element of A and B
        cout << "Array A is: " << endl;
        for (int i=0; i<size; i++) {
            cout << A[i] << " ";
        }
        cout << "\nArray B is: " << endl;
        for (int i=0; i<size-2; i++) {
            cout << B[i] << " ";
        }
        delete [] A;
        delete [] B;
    }    
    return 0;
}
