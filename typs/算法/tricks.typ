= 性能调优
数组上的元素，不能真正的删除，只能覆盖。
```cpp
for (int i = 0; i < array.size(); i++) {
    if (array[i] == target) {
        array.erase(i);
    }
}
```
这个代码看上去好像是O(n)的时间复杂度，其实是O(n^2)的时间复杂度，因为erase操作也是O(n)的操作。

= 数值转换
== char to int
```cpp
int num = static_cast<int>(ch); // 会将char转换为对应的ascii码
```

```cpp
int num = ch - '0'; // 会将char转换为对应的数字
```

== string to int
```cpp
int num = stoi(str);
```

== int to string
```cpp
string str = to_string(num);
```


== 快速找到v离k最近的k的倍数
"Align-Up" 操作
```cpp
return (v + k - 1) & ~(k - 1);
```

== 优先队列 priority_queue
默认是一个大根堆，如果需要小根堆，可以传入一个比较函数。
传入的比较函数需要满足小根堆的性质：如果传入的比较函数返回true，则上下节点会进行位置互换，默认插入的元素是堆的根节点，因此我们如果要构造一个小根堆，则需要传入的比较函数为判断 a > b 这种大于关系。

= 数论
== 1.快速探究是否为2的幂
```cpp
bool isPowerOfTwo(int n) {
    return n > 0 && (n & (n - 1)) == 0;
}
```


= 有序数组
查重，找众数可以考虑：
- nums[i] == nums[i+1]
- 摩尔投票法