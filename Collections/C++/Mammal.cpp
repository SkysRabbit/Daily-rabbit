#include <iostream> // cin, cout, string
#include <new>
#include <string>
using namespace std;

class Mammal {
protected:
    int hp;
    double speed;
public:
    Mammal() {
        hp = 100;
        speed = 25.0;
        cout << "Mammal constructor is created!" << endl;
    }
    ~Mammal() {
        cout << "Mammal destructor is passed!" << endl;
    }
    void breathing() {
        cout << "Breathing~" << endl;
    }
    virtual void makeSound() {
        cout << "Override sound function" << endl;
    }
    // pure virtual function
    virtual void walk() = 0;
};

class Cat : public Mammal {
public:
    Cat() {
        cout << "Cat constructor is created" << endl;
    }
    ~Cat() {
        cout << "Cat destructor is passed" << endl;
    }
    virtual void makeSound() override {
        cout << "Cat Meow~~" << endl;
    }
    virtual void walk() override {
        cout << "Cat walks" << endl;
    }
};

class Dog : public Mammal {
public:
    Dog() { // constructor can have arguments
        cout << "Dog constructor is created" << endl;
    }
    ~Dog() { // destructor cannot have any argument
        cout << "Dog destructor is invoked" << endl;
    }
    virtual void makeSound() override {
        cout << "Dog barks" << endl;
    }
    virtual void walk() override {
        cout << "The way dogs walk is similar with cats" << endl;
    }
};

class Human : public Mammal {
protected:
    bool has_creativity;
public:
    Human() {
        cout << "Human constructor is triggered" << endl;
    }
    ~Human() {
        cout << "Human destructor is invoked" << endl;
    }
    virtual void makeSound() override {
        cout << "We make sound. We also talk using languages" << endl;
    }
    virtual void walk() override {
        cout << "We use our feets to walk" << endl;
    }
    // setter and getter
    void setCreativity(bool x) {
        has_creativity = x;
    }
    bool getCreativity() {
        return has_creativity;
    }
    // member function
    void Discipline() {
        if (has_creativity) {
            cout << "That's wonderful!" << endl;
        }
        else {
            cout << "Mmmm....." << endl;
        }
    }
};

int main(int argc, const char * argv[]) {
    // Mammal cannot be instantiated because it is an abstract class
    Human aPerson;
    aPerson.walk();
    aPerson.makeSound();
    aPerson.breathing();
    aPerson.setCreativity(true);
    aPerson.Discipline();
    
    Cat aCat;
    aCat.breathing();
    aCat.makeSound();
    aCat.walk();
    
    Dog aDog;
    aDog.breathing();
    aDog.makeSound();
    aDog.walk();
    return 0;
}
