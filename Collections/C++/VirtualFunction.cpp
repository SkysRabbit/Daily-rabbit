#include <iostream> // cin, cout, string
#include <new>
#include <string>
using namespace std;

class Student {
public:
    virtual void calcTuition() {
        cout << "We're in Student::calcTuition" << endl;
    }
};

class GraduateStudent : public Student {
public:
    virtual void calcTuition() override {
        cout << "We're in GraduateStudent::calcTuition" << endl;
    }
};

void fn(Student& st) {
    st.calcTuition(); // we don't know which class is now
}

int main(int argc, const char * argv[]) {
    // now they can identify which one is now
    Student s;
    fn(s);
    GraduateStudent gs;
    fn(gs);
    return 0;
}
