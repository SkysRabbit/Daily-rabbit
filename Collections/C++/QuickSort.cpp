#include <iostream> // cin, cout, string
#include <new>
#include <string>
using namespace std;

void swapValue(int* a, int* b) {
    int temp;
    temp = *a;
    *a = *b;
    *b = temp;
}

// quicksort, low and high are index
int partitionValue(int arr[], int low, int high) {
    int pivot = arr[high];
    int i = low-1; // i is the partition point
    
    for (int j=low; j<=high-1; j++) { 
        if (pivot >= arr[j]) { // comparison
            // swap two values
            i++;
            swapValue(&arr[i], &arr[j]);
        }
    }
    // Position pivot to partition point(i+1)
    swapValue(&arr[high], &arr[i+1]);
    return i+1;
}

void QuickSort(int arr[], int low, int high) {
    if (low < high) {
        int pi = partitionValue(arr, low, high);
        
        QuickSort(arr, low, pi-1);
        QuickSort(arr, pi+1, high);
    }
}

int main(int argc, const char * argv[]) {
    int A[10];
    for (int i=0; i<10; i++) {
        A[i] = rand() % 100;
    }
    
    QuickSort(A, 0, 9);
    // print the result
    for (int i=0; i<10; i++) {
        cout << A[i] << " ";
    }
    return 0;
}
