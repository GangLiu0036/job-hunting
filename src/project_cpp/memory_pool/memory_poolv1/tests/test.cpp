#include <iostream>

using namespace std;

int main()
{
    char a = '9';
    a += 1;
    cout << static_cast<int>(a) << endl;
    cout << a - '0' << endl;
    return 0;
}