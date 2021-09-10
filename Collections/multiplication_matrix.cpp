#include <iostream> // cin, cout
#include <new>
#include <string>
using namespace std;

int main(int argc, const char * argv[]) {
    int row_a=0, col_a=0, row_b=0, col_b=0;
    int val;
    cout << "Please enter row and column of array A: ";
    cin >> row_a >> col_a;
    cout << "Please enter row and column of array B: ";
    cin >> row_b >> col_b;
    while (col_a != row_b) {
        cout << "Size of column A must be the same as the size of row B!\n";
        cout << "Please enter row of array B again: ";
        cin >> row_b;
    }
    
    int A[row_a][col_a], B[row_b][col_b], C[row_a][col_b];
    // After multiplication, the size of result array must be row_a by col_b
    for (int r=0; r<row_a; r++) {
        for (int c=0; c<col_a; c++) {
            cout << "Enter array A[" << (r+1) << "][" << (c+1) << "]: ";
            cin >> val;
            A[r][c] = val;
        }
    }
    
    for (int r=0; r<row_b; r++) {
        for (int c=0; c<col_b; c++) {
            cout << "Enter array B[" << (r+1) << "][" << (c+1) << "]: ";
            cin >> val;
            B[r][c] = val;
        }
    }
    
    cout << "Here is array A you entered: \n";
    for (int i=0; i<row_a; i++) {
        for (int j=0; j<col_a; j++) {
            cout << A[i][j] << " ";
        }
        cout << "\n";
    }
    
    cout << "Here is array B you entered: \n";
    for (int i=0; i<row_b; i++) {
        for (int j=0; j<col_b; j++) {
            cout << B[i][j] << " ";
        }
        cout << "\n";
    }
    
    // perform matrix multiplication
    // The pattern is C11=A11*B11+A12*B21+A13*B31+...
    // initialization of matrix C
    for (int i=0; i<row_a; i++) {
        for (int j=0; j<col_b; j++) {
            C[i][j] = 0;
        }
    }
    
    for (int i=0; i<row_a; i++) {
        for (int j=0; j<col_b; j++) {
            for (int k=0; k<col_a; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    
    cout << "The muliplication of matrix A and B is: \n";
    for (int i=0; i<row_a; i++) {
        for (int j=0; j<col_b; j++) {
            cout << C[i][j] << " ";
        }
        cout << "\n";
    }
    return 0;
}
