#include <iostream>
#include <string>
using namespace std;

std::string test_return_string()
{
    std::string result = "11111111";
    return result;
}

int main()
{
    std::string result = test_return_string();

    cout << (void *)result.data() << endl;
    for (int i = 0; i < 10; ++i)
    {
        cout << "hello world" << endl;
    }
}
