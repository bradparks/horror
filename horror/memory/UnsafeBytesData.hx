package horror.memory;

/**
*   Underliying data for efficiently data access
**/

#if html5
typedef UnsafeBytesData = horror.memory.JSFastBytesData;

#elseif flash_memory_domain
typedef UnsafeBytesData = Int;

#elseif cpp
typedef UnsafeBytesData = haxe.io.BytesData;

#else
typedef UnsafeBytesData = horror.memory.ByteArray.ByteArrayData;

#end
