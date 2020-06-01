#include <iostream>
#include <string>
using namespace std;

std::string result = "11111111";

std::string test_return_string()
{
    // When compliled with _GLIBCXX_USE_CXX11_ABI=0, if we don't modify the result, then
    // the result returned will use result's data directly, no copy will happen. That' the
    // copy-on-write. But this does not confirm to the c++ standard, so the new ABI drop this.
    // when _GLIBCXX_USE_CXX11_ABI=1, no matter modify or not, a copy will happen.
    // https://stackoverflow.com/questions/12199710/legality-of-cow-stdstring-implementation-in-c11
    // result[0] = '0';
    cout << "Address in test_return_string: " << (void *)result.data() << endl;
    return result;
}

int main()
{
    std::string result = test_return_string();

    cout << "Address in main: " << (void *)result.data() << endl;
    for (int i = 0; i < 10; ++i)
    {
        cout << "hello world" << endl;
    }
}
