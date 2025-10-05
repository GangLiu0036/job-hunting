#pragma once

#include <iostream>
#include <mutex>

namespace memory_pool // we set a namespace to avoid conflict with other libraries
{
    // first we need to define some macro parameters
    #define MEMORY_POOL_NUM 128
    #define BASE_SLOT_SIZE 8
    #define MAX_SLOT_SIZE 512 // we set 512 Bytes as the max slot size considering the overhead compared new/malloc command.
    
    // then we need to define the slot and MemoryPool class
    struct Slot
    {
        Slot* next;
    };

    class MemoryPool
    {
    public:
        MemoryPool();
        MemoryPool(size_t BlockSize);    // at first we set the bolck num = 1, and the block size = BlockSize
        ~MemoryPool();

        void init(size_t size);
        void* allocate();
        void deallocate(void*);

    private:
        void allocateNewBlock();    // if the current block is full, we will allocate a new block
        size_t padPointer(void* ptr, size_t align);  // return the offset of the pointer to the align boundary
    
    private:
        int BlockSize_;
        int SlotSize_;
        Slot* firstBlock_;
        Slot* curSlot_;
        Slot* lastSlot_;
        Slot* freeList_; // a list linked a set of free slots

        std::mutex mutexForFreeList_; // a mutual exclusion variable to protect the operation onfree list 
        std::mutex mutexForBlock_; // a mutual exclusion variable to protect the operation on block
    };

    class HashBucket{
    public:
        static void initMemoryPool();
        static MemoryPool& getMemoryPool(int index);

        static void* useMemory(size_t size);
        static void freeMemory(void* ptr, size_t size);

        template<typename T, typename... Args>
        static T* newElement(Args&&... args);

        template<typename T>
        static void deleteElement(T* ptr);
    };
}