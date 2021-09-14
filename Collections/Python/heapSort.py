# Heap sort: root has the minimum value, etc.
# n: array size 
# i: current position
def heapify(arr, n, i):
    largest = i # largest as root
    l = 2 * i + 1 # left side
    r = 2 * i + 2 # right side
    
    if l < n and arr[i] < arr[l]:
        largest = l
    
    if r < n and arr[largest] < arr[r]:
        largest = r
        
    if largest != i:
        arr[i], arr[largest] = arr[largest], arr[i]
        heapify(arr, n, largest)
        
def heapSort(arr):
    n = len(arr)
    
    for i in range(n//2-1, -1, -1):
        heapify(arr, n, i)
        
    for i in range(n-1, 0, -1):
        arr[i], arr[0] = arr[0], arr[i]
        heapify(arr, i, 0)
        
if __name__ == '__main__':
    arr = [12, 13, 2, 4, 6, 19, 8, 0]
    heapSort(arr)
    print("The sorted array is ")
    for i in range(len(arr)):
        print(arr[i])
