#include "../include/MemoryPool.h"
#include <cassert>

namespace memory_pool
{
    MemoryPool::MemoryPool()
        : BlockSize_(4096),
          SlotSize_(4096 / 1024),
          firstBlock_(nullptr),
          curSlot_(nullptr),
          lastSlot_(nullptr),
          freeList_(nullptr)
    {}
    
    MemoryPool::MemoryPool(size_t BlockSize)
    : BlockSize_(BlockSize),
      SlotSize_(BlockSize / 1024),
      firstBlock_(nullptr),
      curSlot_(nullptr),
      lastSlot_(nullptr),
      freeList_(nullptr)
    {}
    
    MemoryPool::~MemoryPool()
    {
        Slot* cur = firstBlock_;
        while (cur)
        {
            Slot* next = cur->next;
            // delete cur;
            operator delete(reinterpret_cast<void*>(cur));
            cur = next;
        }
    }
    
    void MemoryPool::init(size_t size)
    {
        assert(size > 0);
        SlotSize_ = size;
        firstBlock_ = nullptr;
        curSlot_ = nullptr;
        lastSlot_ = nullptr;
        freeList_ = nullptr;
    }

    void* MemoryPool::allocate()
    {
        // check if there is a free slot in the current block
        if (freeList_ != nullptr)
        {
            std::lock_guard<std::mutex> lock(mutexForFreeList_); // lock the free list
            if (freeList_ != nullptr) // check if the slot in the free list is empty
            {
                // find the first free slot in the current free list and return it
                Slot* slot_ptr = freeList_;
                freeList_ = slot_ptr->next;
                return slot_ptr;
            }
        }
        
        
        Slot* slot_ptr;
        // if there is no free slot in the current block, allocate a new block
        {
            std::lock_guard<std::mutex> lock(mutexForFreeList_); // lock the operation on free list 
    
            if (curSlot_ >= lastSlot_) // if the current block is full, allocate a new block
            {
                allocateNewBlock(); // the block is full, allocate a new block, and the curSlot will
                                    // be updated to point the first slot of the new block
            }

            slot_ptr = curSlot_;
            curSlot_ = curSlot_ + SlotSize_ / sizeof(Slot); // let the curSlot pointer to the next block
        }
        
        return slot_ptr;
    }

    void MemoryPool::deallocate(void* ptr)
    {
        if (ptr)
        {
            std::lock_guard<std::mutex> lock(mutexForFreeList_); // lock the operation on free list
            reinterpret_cast<Slot*>(ptr)->next = freeList_; // insert the deallocated slot to the head of the free list
            freeList_ = reinterpret_cast<Slot*>(ptr); // update the head of the free list
        }
    }

    void MemoryPool::allocateNewBlock()
    {
        // std::lock_guard<std::mutex> lock(mutexForBlock_); // lock the block
        void *newBlock = operator new(BlockSize_); // allocate a new block
        // insert the new block to the head of the Block list
        Slot* newBlock_ptr = reinterpret_cast<Slot*>(newBlock);
        newBlock_ptr->next = firstBlock_;
        firstBlock_ = newBlock_ptr;

        char* block_body = reinterpret_cast<char*>(newBlock) + sizeof(Slot*); // the memory block contains the block pointer and the body of the block
        size_t padding_size = padPointer(block_body, SlotSize_); // return the offset (bytes)
        curSlot_ = reinterpret_cast<Slot*>(block_body + padding_size);

        lastSlot_ = reinterpret_cast<Slot*>(
            reinterpret_cast<size_t>(newBlock) + 
            BlockSize_ - SlotSize_ + 1);

        freeList_ = nullptr; // reset the free list
    }

    size_t MemoryPool::padPointer(void* ptr, size_t align)
    {
        // size_t addr = reinterpret_cast<size_t>(ptr);
        // return (addr + align - 1) & ~(align - 1);
        return align - (reinterpret_cast<size_t>(ptr) % align);
    }

    void HashBucket::initMemoryPool()
    {
        for (int i=0; i<MEMORY_POOL_NUM; ++i)
        {
            getMemoryPool(i).init((i+1) * BASE_SLOT_SIZE);
        }
    }

    void* HashBucket::useMemory(size_t size)
    {
        if (size <= 0)
            return nullptr;
        if (size > MAX_SLOT_SIZE) // if the size is greater than MAX_SLOT_SIZE, use new operator
            return operator new(size);

        return getMemoryPool(((size + 7) / BASE_SLOT_SIZE) - 1).allocate();
    }

    void HashBucket::freeMemory(void* ptr, size_t size)
    {
        if (!ptr)
            return;
        if (size > MAX_SLOT_SIZE)
        {
            operator delete(ptr);
            return;
        }

        getMemoryPool(((size + 7) / BASE_SLOT_SIZE) - 1).deallocate(ptr);
    }

    // Singleton Management
    MemoryPool& HashBucket::getMemoryPool(int index)
    {
        static MemoryPool memoryPool[MEMORY_POOL_NUM];
        return memoryPool[index];
    }

    template<typename T, typename... Args>
    T* newElement(Args&&... args){
        T* ptr = nullptr;
        if (ptr = reinterpret_cast<T*>(HashBucket::useMemory(sizeof(T))) != nullptr)
        {
            new(ptr) T(std::forward<Args>(args)...);
        }
        
        return ptr;
    }

    template<typename T>
    static void deleteElement(T* ptr){
        if (ptr)
        {
            ptr->~T();
            HashBucket::freeMemory(reinterpret_cast<void*>(ptr), sizeof(T));
        }
    }
}