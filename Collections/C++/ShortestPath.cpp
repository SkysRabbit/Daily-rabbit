// The purpose of this program is to find the shortest path using dynamic programming (i.e. Floyd's shortest path algorithm)
#include <iostream> // cin, cout, string
#include <new>
#include <string>
using namespace std;
# define INF 90000 // sufficiently large value
# define n 5
void printMatrix(int D[][n]);
void printPath(int, int);
int P[n][n]; // global variable

void func1(int W[][n], int P[][n]) {
    int i, j, k;
    int D[n][n];
    
    // duplicate W and D
    for (i=0; i<n; i++) {
        for (int j=0; j<n; j++) {
            D[i][j] = W[i][j];
        }
    }
    
    for (k=0; k<n; k++) {
        for (i=0; i<n; i++) {
            for (j=0; j<n; j++) {
                if ((D[i][k] + D[k][j]) < D[i][j] && (D[i][k] != INF && D[k][j] != INF)) {
                    P[i][j] = k;
                    D[i][j] = D[i][k] + D[k][j];
                }
            }
        }
    }
}

void printMatrix(int D[][n]) {
    cout << "The matrix contains shortest path is " << endl;
    for (int i=0; i<n; i++) {
        for (int j=0; j<n; j++) {
            cout << D[i][j] << " ";
        }
        cout << endl;
    }
}

// print shortest path from p to q
void printPath(int p, int q) {
    if (P[p][q] != -1) {
        printPath(p, P[p][q]); // intend to find the nearest point of p
        cout << p << endl;
        cout << P[p][q] << endl;
        cout << q << endl;
        cout << "n" << P[p][q] << endl;
        printPath(P[p][q], q);
    }
}

int main(int argc, const char * argv[]) {
    int W[n][n] = {{0, 1, INF, 1, 5},
                 {9, 0, 3, 2, INF},
                 {INF, INF, 0, 4, INF},
                 {INF, INF, 2, 0, 3},
                 {3, INF, INF, INF, 0}
    };
    
    // initialize P matrix
    // P will be the largest index in the shortest path of Vertice i and j
    // P will be 0 if there is no vertice between Vertice i and j
    for (int i=0; i<n; i++) {
        for (int j=0; j<n; j++) {
            P[i][j] = -1;
        }
    }
    
    func1(W, P);
    printPath(4, 2); // strange thing
    return 0;
}
