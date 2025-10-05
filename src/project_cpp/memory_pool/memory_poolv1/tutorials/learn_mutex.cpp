/*
 * std::mutex 学习代码
 * 包含各种 mutex 用法示例和最佳实践
 */
#ifdef _WIN32
#include <windows.h>
#endif

#include <iostream>
#include <thread>
#include <mutex>
#include <vector>
#include <chrono>

// 示例1：基本 mutex 使用
void basic_mutex_example() {
    std::cout << "=== 示例1：基本 mutex 使用 ===" << std::endl;
    
    std::mutex mtx;
    int shared_counter = 0;
    
    auto increment_task = [&]() {
        for (int i = 0; i < 1000; ++i) {
            mtx.lock();    // 手动加锁
            shared_counter++;
            mtx.unlock();  // 手动解锁
        }
    };
    
    std::thread t1(increment_task);
    std::thread t2(increment_task);
    
    t1.join();
    t2.join();
    
    std::cout << "最终计数器值: " << shared_counter << " (应该是2000)" << std::endl;
    std::cout << std::endl;
}

// 示例2：使用 std::lock_guard (RAII)
void lock_guard_example() {
    std::cout << "=== 示例2：使用 std::lock_guard (RAII) ===" << std::endl;
    
    std::mutex mtx;
    int shared_counter = 0;
    
    auto increment_task = [&]() {
        for (int i = 0; i < 1000; ++i) {
            std::lock_guard<std::mutex> lock(mtx); // 自动加锁和解锁
            shared_counter++;
        }
    };
    
    std::thread t1(increment_task);
    std::thread t2(increment_task);
    
    t1.join();
    t2.join();
    
    std::cout << "最终计数器值: " << shared_counter << " (应该是2000)" << std::endl;
    std::cout << std::endl;
}

// 示例3：使用 std::unique_lock (更灵活)
void unique_lock_example() {
    std::cout << "=== 示例3：使用 std::unique_lock (更灵活) ===" << std::endl;
    
    std::mutex mtx;
    int shared_counter = 0;
    
    auto increment_task = [&]() {
        for (int i = 0; i < 1000; ++i) {
            std::unique_lock<std::mutex> lock(mtx);
            shared_counter++;
            // unique_lock 可以手动解锁
            lock.unlock();
            // 这里可以执行一些不需要锁的操作
            lock.lock(); // 重新加锁
            shared_counter++; // 再次操作共享数据
        }
    };
    
    std::thread t1(increment_task);
    std::thread t2(increment_task);
    
    t1.join();
    t2.join();
    
    std::cout << "最终计数器值: " << shared_counter << " (应该是4000)" << std::endl;
    std::cout << std::endl;
}

// 示例4：try_lock 用法
void try_lock_example() {
    std::cout << "=== 示例4：try_lock 用法 ===" << std::endl;
    
    std::mutex mtx;
    int shared_counter = 0;
    
    auto try_increment_task = [&]() {
        for (int i = 0; i < 1000; ++i) {
            // 尝试获取锁，如果失败就继续其他工作
            if (mtx.try_lock()) {
                shared_counter++;
                mtx.unlock();
            } else {
                // 锁被占用，执行其他工作
                std::this_thread::sleep_for(std::chrono::microseconds(10));
            }
        }
    };
    
    std::thread t1(try_increment_task);
    std::thread t2(try_increment_task);
    
    t1.join();
    t2.join();
    
    std::cout << "最终计数器值: " << shared_counter << std::endl;
    std::cout << std::endl;
}

// 示例5：死锁示例和避免
void deadlock_prevention_example() {
    std::cout << "=== 示例5：死锁避免 ===" << std::endl;
    
    std::mutex mtx1, mtx2;
    int counter1 = 0, counter2 = 0;
    
    // 错误的用法：可能导致死锁
    auto bad_task = [&]() {
        for (int i = 0; i < 100; ++i) {
            mtx1.lock();
            mtx2.lock(); // 如果另一个线程先锁mtx2，这里可能死锁
            counter1++;
            counter2++;
            mtx2.unlock();
            mtx1.unlock();
        }
    };
    
    // 正确的用法：使用 std::lock 同时锁定多个互斥量
    auto good_task = [&]() {
        for (int i = 0; i < 100; ++i) {
            std::lock(mtx1, mtx2); // 同时锁定，避免死锁
            std::lock_guard<std::mutex> lock1(mtx1, std::adopt_lock);
            std::lock_guard<std::mutex> lock2(mtx2, std::adopt_lock);
            counter1++;
            counter2++;
        }
    };
    
    std::thread t1(good_task);
    std::thread t2(good_task);
    
    t1.join();
    t2.join();
    
    std::cout << "计数器1: " << counter1 << ", 计数器2: " << counter2 << " (都应该是200)" << std::endl;
    std::cout << std::endl;
}

// 示例6：保护复杂数据结构
void protect_complex_data() {
    std::cout << "=== 示例6：保护复杂数据结构 ===" << std::endl;
    
    std::mutex mtx;
    std::vector<int> shared_vector;
    
    auto producer_task = [&]() {
        for (int i = 0; i < 100; ++i) {
            std::lock_guard<std::mutex> lock(mtx);
            shared_vector.push_back(i);
        }
    };
    
    auto consumer_task = [&]() {
        int sum = 0;
        for (int i = 0; i < 10; ++i) {
            std::lock_guard<std::mutex> lock(mtx);
            if (!shared_vector.empty()) {
                sum += shared_vector.back();
                shared_vector.pop_back();
            }
        }
        std::cout << "消费者计算的和: " << sum << std::endl;
    };
    
    std::thread producer(producer_task);
    std::thread consumer(consumer_task);
    
    producer.join();
    consumer.join();
    
    std::cout << "向量最终大小: " << shared_vector.size() << std::endl;
    std::cout << std::endl;
}

int main() {
    #ifdef _WIN32
        SetConsoleOutputCP(65001);  // 设置控制台为 UTF-8 编码，避免中文乱码
    #endif

    std::cout << "std::mutex 学习代码" << std::endl;
    std::cout << "====================" << std::endl << std::endl;
    
    basic_mutex_example();
    lock_guard_example();
    unique_lock_example();
    try_lock_example();
    deadlock_prevention_example();
    protect_complex_data();
    
    std::cout << "所有示例执行完成!" << std::endl;
    return 0;
}
