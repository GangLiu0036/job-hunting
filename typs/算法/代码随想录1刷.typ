#import "@preview/cetz:0.4.0"
#import "@preview/equate:0.3.2": equate
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/hydra:0.6.1": hydra

#show: codly-init.with()
#codly(languages: codly-languages)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => pagebreak(weak: true) + it
#show: equate.with(breakable: true, sub-numbering: true)
#set math.equation(numbering: "(1.1)")
#set page(paper: "a4", margin: (y: 4em), numbering: "1", header: context {
  align(right, emph(hydra(2)))
  line(length: 100%)
})

= 《代码随想录》1刷感悟
《代码随想录》给没有科班基础和准备时间紧张的程序员提供了一个非常好的学习机会。本文是作者在刷完第一遍《代码随想录》后的一些感悟，主要包括算法理解和性能优化。

#rect(fill: aqua)[尚未完结，持续更新中]

致敬作者#link("https://github.com/youngyangyang04")[程序员Carl]，

感激不尽！

#outline()
#pagebreak()

== 基本输入输出
为补充部分，主要以C++为例。
默认我们喜欢用 std::cin 和 std::cout 进行输入输出。std::cin可以读取整行，但需要注意的是，如果单行数据内部有空格，则会在空格之前停止读取。因此如果我们需要读取单行数据，则需要使用std::getline。
```cpp
string line;
getline(cin, line);
```



== 数组
=== 理论和基本使用
数组是存放在连续内存空间上的相同类型数据的集合。它的特点是：
- 查找快：因为数组在内存中是连续的，所以可以通过下标直接访问元素，时间复杂度为O(1)。
- 插入和删除慢：因为数组在内存中是连续的，所以插入和删除元素时，需要移动其他元素，时间复杂度为O(n)。

常用的定义方式如下：
- 一维情况：
```cpp
// 最基本方式
int arr[10]; 

// 如果要使用变量作为数组的长度，需要把变量设置为常量类型
const int len = 10;
int arr[len];

// 也可以使用stl的vector
vector<int> arr(10);

// 也可以使用new动态分配内存，此时如果使用变量则不需要设置为常量类型
int* arr = new int[10];
```

- 多维情况：
```cpp
int arr[10][10];

// stl的vector
vector<vector<int>> arr(10, vector<int>(10));

// 也可以使用new动态分配内存
int* arr = new int[10][10];

int** arr = new int*[10];
for (int i = 0; i < 10; i++) {
    arr[i] = new int[10];
}
```

在C++中，数组内部的地址空间是连续的，对于多维的情况也是如此。但在java，go等语言中，多维数组内部的地址空间不一定连续。

=== 查找算法
#set enum(numbering: "I.")

通常我们可以使用sort函数快速对一个数组进行排序，而无需手动写。
sort默认是快排，它是时间复杂度为O(nlogn)，空间复杂度为O(logn)。

+ 二分查找

二分查找只适用于有序数组，时间复杂度为O(logn)。
- 思路：通过不断对比区间最中间元素与区间两端元素的大小，来不断缩短区间范围，直至找到目标元素。

注意点：
- 区间设置很重要，个人经验是采用闭区间的方式，即假设我们区间为[left, right]，那么当left == right时，区间中只有一个元素，即找到了目标元素。
- 注意如果区间长度为偶数时，中间元素为左区间的最后一个元素。因为C++, python, go等语言基本都是向下取整，即 $"mid" = floor(("left" + "right") / 2)$。

+ 快排

+ 归并排序

+ 堆排序

+ 桶排序

=== 双指针
1. 原地移除元素
- 思路：快指针遍历数组，慢指针记录新数组的位置。如果快指针的元素不等于目标元素，则将快指针的元素赋值给慢指针，然后慢指针加1。
- 注意：注意如果是字符串的话，也可以这么做，c++语言最后记得resize一下处理后的string类型。
- 复杂度：时间复杂度为O(n)，空间复杂度为O(1)。

2.三数之和
- 思路：先排序，然后使用双指针遍历数组，找到三个数，使得它们的和为目标值。
- 注意：去重，简单粗暴我们可以用unordered_set，但可能会超时，此时我们就需要考虑是否在选择元素的时候就进行去重。
- 复杂度：时间复杂度为O(n^2)，空间复杂度为O(1)。
- 拓展：对于n(n>3)数之和，我们可以先固定一个数，然后对剩下的n-1个数使用双指针法。

3.滑动窗口
- 思路：使用双指针，一个指针指向窗口的左边界，一个指针指向窗口的右边界。当窗口内的元素满足条件时，调整窗口大小或者更新结果。
- 注意：滑动不一定只能用双指针实现，还可以用队列实现。
- 复杂度：时间复杂度为O(n)，空间复杂度为O(1)。

4.翻转链表（头插法）
- 思路：顺序遍历，使用头插法，将链表的节点一个个插入到新链表的头部。
- 注意：个人感觉链表相关的题目，在有虚拟头节点的情况下会比较简单。
- 复杂度：时间复杂度为O(n)，空间复杂度为O(1)。

写法如下：
```cpp
ListNode* reverseList(ListNode* head) {
    ListNode* newHead = nullptr; // 虚拟头节点
    while (head) {
        ListNode* next = head->next; // 保存下一个节点
        head->next = newHead; // 将当前节点插入到新链表的头部
        newHead = head; // 更新新链表的头部
        head = next; // 更新当前节点
    }
    return newHead;
}

```

5.删除链表的倒数第n个节点
- 思路：快慢指针，快指针先走n步，然后快慢指针一起走，当快指针走到链表末尾时，慢指针就是倒数第n个节点。
- 复杂度：时间复杂度为O(n)，空间复杂度为O(1)。

6.环形链表
- 思路：快慢指针，快指针每次走两步，慢指针每次走一步。如果链表有环，则快慢指针一定会相遇。否则，则快指针会先走到链表末尾。
- 复杂度：时间复杂度为O(n)，空间复杂度为O(1)。
- 拓展：找到环形链表的入口：还是沿用上述思路，但此时快慢指针第一次相遇后，把两个新指针分别置为链表头和相遇点，它们每次都走一步，当它们再次相遇时，就是环形链表的入口。可以这样做的原因如下：
#pad(left: 1cm)[
  a. 设链表到环形链表入口的距离为x，环长为c=a+b，则快慢指针相遇时，慢指针走了x+a步，快指针每次比慢指针都多走一步，则走了2(x+a)步；\
  b. 由于快指针更早进入环，则我们假设快慢指针相遇时，快指针在环里面走了n圈，则有：nc=2(x+a)-(x+a)=x+a；\
  c. 又因为一圈的长度c=a+b，则有：nc=x+a，即：n(a+b)=x+a，则：x=(n-1)(a+b)+b；\
  d. 此时把新指针new1重新置为链表头，新指针new2从相遇点重新开始，当它们再次相遇时,指针new1走了x步，指针new2则走了(n-1)(a+b)+b=nc+b步；\
  e.无论n是多少，指针new2都走了nc+b步，而nc步刚好是环的长度的整数倍，不影响找到环入口，所以指针new2在环里面走了b步，即走到了环形链表的入口。
]


=== 前缀和
前缀和主要利用数列求和的性质，可以在O(1)时间复杂度内求出任意区间内的和。

== 链表
又爱又恨，爱是因为该类数据结构的特点：
- 插入和删除的效率很高，时间复杂度为O(1)。
- 查找的效率很低，时间复杂度为O(n)。
恨是因为链表指针容易出错，经常会出现指针指向错误的情况。debug也不方便。

这里需要提醒自己需要注意的几个方面：
- 链表的定义
```cpp
struct ListNode{
  int val;
  ListNode* next;

  ListNode(int x): val(x), next(nullptr){}
  ListNode(int x, ListNode* next): val(x), next(next){}
};
```
- 链表的初始化
```cpp
ListNode* head = new ListNode(1);
head->next = new ListNode(2);
head->next->next = new ListNode(3);
```
- 链表的应用场景：
#pad(left: 1cm)[
  a. STL的list是双向链表结构；\
  b. 链表适用于频繁插入删除但随机访问较少的场景；\
  c. 链表内存分配不连续，适合动态增长的数据结构；
]

== 哈希表
哈希表是一种数据结构，它通过哈希函数将键映射到数组中的一个位置，从而实现快速的查找、插入和删除。
语法：
```cpp
std::unordered_map<int, int> map1; // 基于哈希表，不保持元素顺序
std::map<string, int> map2; // 基于红黑树，默认按key升序排列(std::less<string>)
std::map<string, int, std::greater<string>> map3; // 基于红黑树，按key降序排列
```
注意：哈希表内部的元素为`pair<key, value>`，因此我们可以通过first和second来访问key和value。

== 字符串
字符串是字符的集合，通常用于存储和处理文本数据。在C++中，字符串通常以`std::string`类型表示。
语法：
```cpp
std::string str1;
std::string str2 = "hello";
std::string str3 = str2;
```
注意：
- 字符串的末尾有一个空字符`'\0'`，表示字符串的结束。如果我们使用char数组来存储字符串，则需要手动在末尾添加`'\0'`，声明数组长度时也需要把这个空字符考虑进去。
- string to int: 使用stoi函数，int to string: 使用to_string函数。
- 字符串的拼接：使用`+`操作符，或者使用`append`函数。
- 字符串的比较：使用`==`操作符，或者使用`compare`函数。
- 字符串的查找：使用`find`函数，或者使用`rfind`函数。
- 字符串的替换：使用`replace`函数。
- 字符串的插入：使用`insert`函数。
- 字符串的删除：使用`erase`函数，注意这个修改复杂度是O(n)。

=== 子串匹配
子串匹配是字符串处理中非常常见的操作，通常用于查找一个字符串中是否包含另一个字符串。通常在C++里，可以使用 string 的 find 函数来实现。
语法：
```cpp
std::string str1 = "hello";
std::string str2 = "hello";
int pos = str1.find(str2);
if (pos != std::string::end) {
    std::cout << "str2 is in str1" << std::endl;
}
```

子串匹配算法KMP:
复杂度：时间复杂度为O(n+m)，空间复杂度为O(m)。其中 m 为模式串的长度，n 为主串的长度。

在介绍这个算法前，我们需要先介绍几个概念：
假设字符串s长度为l
- 前缀: 不包含最后一个字符的所有连续子串
- 后缀: 不包含第一个字符的所有连续子串  
- next 数组: 记录模式串每个位置的最长相等前后缀长度

与传统暴力匹配不同，KMP 利用已匹配信息避免主串指针回退：
1. 匹配失败时，模式串滑动到 `next[j]` 位置继续匹配
2. 保证滑动后模式串前缀与主串已匹配部分对齐
注意：这里的 `j` 指的是字符串匹配过程中的匹配位置，
与next数组构造中的 `j` 含义不同。

next 数组只与模式串 p 相关，构造过程：

```cpp
vector<int> getNext(string& p) {
    int n = p.size();
    vector<int> next(n, 0);
    int j = 0;  // 指向前缀末尾
    
    for (int i = 1; i < n; i++) {
        // 不匹配时回退到前一个位置的前缀长度
        while (j > 0 && p[i] != p[j]) {
            j = next[j - 1];
        }
        
        // 匹配成功，前后缀长度增加
        if (p[i] == p[j]) {
            j++;
        }
        
        next[i] = j;  // 记录当前位置的最长前后缀
    }
    return next;
}
```

关键理解：
- next数组代码里的`j` 指向当前匹配的前缀末尾，`i` 指向当前匹配的后缀末尾
- 目标：确保 `p[0:j] == p[i-j:i]`（前缀 = 后缀）
- 当 `p[i] != p[j]` 时，回退到 `next[j-1]` 因为：
  - `next[j-1]` 表示 `p[0:j-1]` 的最长相等前后缀长度
  - 这是下一个可能匹配的位置，确保不跳过有效匹配

=== 算法优势
- 主串指针不回溯：避免重复比较
- 利用已匹配信息：通过 next 数组智能跳转
- 线性时间复杂度：每个字符最多比较两次


== 栈与队列
- 栈stack：后入先出(LIFO)，通过top()访问栈顶元素
- 队列queue：先进先出(FIFO)，通过front()访问队头元素  
- 双端队列deque：两端都可操作，支持push_front/pop_front和push_back/pop_back
- 优先队列priority_queue：堆结构，默认大根堆，通过top()访问最大元素

比较函数构造：
```cpp
struct cmp{
  bool operator()(int a, int b){
    return a > b; // 构造小根堆, 因为默认新元素从根节点插入，因此如果传入的比较函数返回true，则上下节点会进行位置互换，因此我们如果需要构造小根堆，则需要传入的比较函数为判断 a > b 这种大于关系。
  }
};

std::priority_queue<int, std::vector<int>, cmp> pq;
```
为什么比较函数需要这么构造，是因为priority_queue的第三个模板参数需要的是一个函数对象类型（具有operator()的类），而cmp虽然是结构体，但它就是类，满足这个要求。通常这样写是因为语法更简单。并且STL中的函数对象（如 less, greater）都是用 struct 定义的


注意：
stack和queue不是容器，而是适配器，它们内部依赖于其他容器实现。
- stack 默认使用 deque 作为底层容器，但可以指定其他序列容器如list, array等
- queue 默认使用 deque 作为底层容器，但可以指定其他序列容器如list, array等
- priority_queue 默认使用 vector 作为底层容器，但可以指定其他随机访问容器如vector, array等

=== 单调队列
单调队列是一种特殊的队列，它的元素是单调的，即队头元素是队列中最大的元素，队尾元素是队列中最小的元素。

单调队列的实现，可以用双端队列来实现。
```cpp
class MonotonicQueue{
  std::deque<int> dq;
  void push(int x){
    // 维护单调递减：移除所有小于x的元素
    while (!dq.empty() && dq.back() < x) {
        dq.pop_back();
    }
    dq.push_back(x);  // 加入新元素
  }

  void pop(int x){
      // 只有当要弹出的元素是队头最大值时才弹出
      if (!dq.empty() && dq.front() == x) {
          dq.pop_front();
      }
  }

  int max() const {
      return dq.front();  // 队头始终是最大值
  }
  
  bool empty() const {
      return dq.empty();
  }
};
```

== 二叉树
C++中map、set、multimap，multiset的底层实现都是平衡二叉搜索树，所以map、set的增删操作时间时间复杂度是O(logn)。
unordered_map、unordered_set，unordered_map、unordered_set底层实现是哈希表，所以unordered_map、unordered_set的增删操作时间时间复杂度是O(1)。

几种二叉树类型：
- 满二叉树：除了叶子节点，每个节点都有两个子节点，且所有叶子节点都在同一层。
- 完全二叉树：除了最后一层，其他层都是满的，最后一层从左到右连续。
- 平衡二叉树：每个节点的左右子树高度差不超过1。
  - 对于n层的平衡二叉树，节点数介于 Fibonacci 数列和满二叉树之间，
  - 最多为 2^n - 1 个节点（满二叉树）。
- 二叉搜索树：每个节点的左子树的所有节点都小于该节点，右子树的所有节点都大于该节点。
- 红黑树：每个节点都是红色或黑色，根节点是黑色，每个叶子节点都是黑色，每个红色节点的两个子节点都是黑色，从任一节点到其每个叶子节点的所有路径都包含相同数目的黑色节点。
- B树：一种多路平衡搜索树，每个节点可以有多个子节点，每个节点最多有M个子节点（M为B树的阶），每个节点包含多个关键字。根节点至少有2个子节点，其他非叶子节点至少有⌈M/2⌉个子节点。

- B+树：一种多路平衡搜索树，每个节点可以有多个子节点，每个节点包含多个关键字，叶子节点包含所有关键字。
- `B*`树：一种多路平衡搜索树，所有关键字存储在叶子节点中，非叶子节点只存储索引和指向子节点的指针，叶子节点通过指针连接形成有序链表

关于几种二叉树的构造：TODO

为了防止面试被拷打手撕红黑树

+ 首先是树节点的定义：
```cpp
struct TreeNode {
    int val;
    TreeNode *left;
    TreeNode *right;
    TreeNode(int x) : val(x), left(NULL), right(NULL) {}
};
```

// #link()[]

二叉树的存储方式：
+ 链式存储：每个节点包含一个数据域和两个指针域，分别指向左子节点和右子节点。
+ 顺序存储：每个节点存储在数组中，数组下标i为节点编号，左子节点下标为$ 2i+1$，右子节点下标为节点编号$2i+2$。

二叉树的遍历方式：
二叉树是一种特殊的图，我们按照图遍历的特点，也可以把二叉树的分类方式分为深度优先遍历和广度优先遍历两种。
- 深度优先遍历：前序遍历、中序遍历、后序遍历（递归，迭代，栈）
- 广度优先遍历：层序遍历（队列实现）

这里的前中后指的是中间节点在遍历中的位置。

#enum(
  enum.item(1)[前序遍历：
  ```cpp
// 递归版本
void preOrder(TreeNode* root){
  if (root == nullptr) return;
  cout << root->val << " ";
  preOrder(root->left);
  preOrder(root->right);
}

// 迭代版本
void preOrder_iterative(TreeNode* root){
  vector<int> result;
  stack<pair<TreeNode*, bool >> st; // 栈里存元素的含义的是<节点指针, 是否访问过>

  if (root != nullptr) st.push({root, false});

  while (!st.empty()){
    auto [node, visited] = st.top();
    st.pop();

    if (visited) result.push_back(node->val);
    else{
      if (node->right != nullptr) st.push({node->right, false});
      if (node->left != nullptr) st.push({node->left, false});
      st.push({node, true});
    }
  }
  return result;
}
```

  
  ],
  enum.item(2)[中序遍历
```cpp
// 递归版本
void inOrder(TreeNode* root){
  if (root == nullptr) return;
  inOrder(root->left);
  cout << root->val << " ";
  inOrder(root->right);
}

// 迭代版本
void inOrder_iterative(TreeNode* root){
  vector<int> result;
  stack<pair<TreeNode*, bool >> st; // 栈里存元素的含义的是<节点指针, 是否访问过>

  if (root != nullptr) st.push({root, false});

  while (!st.empty()){
    auto [node, visited] = st.top();
    st.pop();

    if (visited) result.push_back(node->val);
    else{
      if (node->right != nullptr) st.push({node->right, false});
      st.push({node, true});
      if (node->left != nullptr) st.push({node->left, false});
    }
  }
  return result;


```

],
  enum.item(3)[后续遍历：
```cpp
// 递归版本
void postOrder(TreeNode* root){
  if (root == nullptr) return;
  postOrder(root->left);
  postOrder(root->right);
  cout << root->val << " ";
}

// 迭代版本
void preOrder_iterative(TreeNode* root){
  vector<int> result;
  stack<pair<TreeNode*, bool >> st; // 栈里存元素的含义的是<节点指针, 是否访问过>

  if (root != nullptr) st.push({root, false});

  while (!st.empty()){
    auto [node, visited] = st.top();
    st.pop();

    if (visited) result.push_back(node->val);
    else{
      st.push({node, true});
      if (node->right != nullptr) st.push({node->right, false});
      if (node->left != nullptr) st.push({node->left, false});
    }
  }
  return result;
```
  
  ],
  enum.item(4)[
层序遍历：
```cpp
// 队列版本
void levelOrder(TreeNode* root){
  vector<int> result;
  queue<TreeNode*> q;
  if (root != nullptr) q.push(root);
  while (!q.empty()){
    auto node = q.front();
    q.pop();
    result.push_back(node->val);
    if (node->left != nullptr) q.push(node->left);
    if (node->right != nullptr) q.push(node->right);
  }
  return result;
}


```
  ]
)

== 二叉树的高度和深度
- 二叉树节点的深度：指从根节点到该节点的最长简单路径边的条数或者节点数（取决于深度从0开始还是从1开始）
- 二叉树节点的高度：指从该节点到叶子节点的最长简单路径边的条数或者节点数（取决于高度从0开始还是从1开始）

求二叉树的高度和深度的代码是一样的，因为本质上树的高度就是树的最大深度：
```cpp
int getHeight(TreeNode* root){
  if (root == nullptr) return 0;
  int leftHeight = getHeight(root->left);
  int rightHeight = getHeight(root->right);
  return max(leftHeight, rightHeight) + 1;
}

int getDepth(TreeNode* root){
  if (root == nullptr) return 0;
  int leftDepth = getDepth(root->left);
  int rightDepth = getDepth(root->right);
  return max(leftDepth, rightDepth) + 1;
}

// 求最小深度
int min_depth = INT_MAX;
void dfs(TreeNode *cur, int depth) {
    if (cur->left == nullptr && cur->right == nullptr) {
        min_depth = min(min_depth, depth);
        return;
    }

    if (cur->left) bfs(cur->left, depth+1);
    if (cur->right) bfs(cur->right, depth+1);
}
```
这里对于高度和深度的求解，可以使用前序遍历也可以使用后序遍历，个人感觉前序遍历更能体现
深度优先搜索（dfs）的思想，并且我们都是需要找到叶子节点才能够判断某一个路径的长度，因此我更倾向于
使用dfs的写法。

== 二叉树遍历与回溯
在二叉树的题目里，出现了一些路径相关的题目，对于这些题目的解法往往涉及回溯思想。这里
的回溯指的是在深度优先搜索时，遍历完当前路径后返回到上一分叉口，然后搜索其他路线。

需要注意的点是：
- 回溯时需要恢复现场，即需要恢复到回溯前的状态
- 使用引用传递（如 vector<int>&）时，需要显式回溯（pop_back()）
- 使用值传递（如 vector<int>）时，递归自动拷贝，不需要显式回溯
- 引用传递节省空间但需要手动维护；值传递代码简洁但空间开销大

代码如下：
```cpp
// 需要显式回溯的情况：使用引用传递或全局变量
void dfs(TreeNode* node, vector<int>& path) {
    if (node == nullptr) return;
    
    path.push_back(node->val);  // 做选择
    
    if (满足条件) {
        // 记录结果
    }
    
    dfs(node->left, path);
    dfs(node->right, path);
    
    path.pop_back();  // 撤销选择（显式回溯）
}

// 不需要显式回溯的情况：使用值传递
void dfs(TreeNode* node, vector<int> path) {  // 值传递，自动拷贝
    if (node == nullptr) return;
    
    path.push_back(node->val);
    
    dfs(node->left, path);   // 每次递归都是新的副本
    dfs(node->right, path);
    
    // 不需要 pop_back()
}
```