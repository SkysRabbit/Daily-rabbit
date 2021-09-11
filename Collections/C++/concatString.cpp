#include <iostream> // cin, cout
#include <new>
#include <string>
using namespace std;

void concatString (char Target[], char Source[]) {
    // find the end of the first string
    int index_tar = 0;
    // traverse the
    while (bool(Target[index_tar]) == 1) {
        index_tar++;
    }
    Target[index_tar] = ' ';
    ++index_tar;
    int index_sor = 0;
    while (bool(Source[index_sor]) == 1) {
        Target[index_tar] = Source[index_sor];
        index_tar++; index_sor++;
    }
    Target[index_tar] = '\0';
}

int main(int argc, const char * argv[]) {
    char firstStr[256];
    cout << "Enter string #1: ";
    cin.getline(firstStr, 128);
    
    char secStr[128];
    cout << "Enter string #2: ";
    cin.getline(secStr, 128);
    
    concatString(firstStr, secStr);
    cout << "\n" << firstStr << endl;
    
    return 0;
}
