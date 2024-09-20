pub const CpuidResult = struct {
    eax: u32,
    ebx: u32,
    edx: u32,
    ecx: u32,
};

// Leaf 0 -> cpu manufacturer id, 12 character ascii register order: EBX,EDX,ECX
/// See https://en.wikipedia.org/wiki/CPUID#Calling_CPUID
pub fn cpuid(leaf: u32, sub_leaf: u32) CpuidResult {
    var eax: u32 = undefined;
    var ebx: u32 = undefined;
    var ecx: u32 = undefined;
    var edx: u32 = undefined;

    asm volatile ("cpuid"
        : [eax] "={eax}" (eax),
          [ebx] "={ebx}" (ebx),
          [ecx] "={ecx}" (ecx),
          [edx] "={edx}" (edx),
        : [leaf] "{eax}" (leaf),
          [sub_leaf] "{ecx}" (sub_leaf),
        : "memory"
    );

    return CpuidResult{
        .eax = eax,
        .ebx = ebx,
        .ecx = ecx,
        .edx = edx,
    };
}

pub fn manufacturerId() [12]u8 {
    const result = cpuid(0, 0);
    const manufacturer_bytes = [_]u8{
        @truncate(0xFF & result.ebx),
        @truncate(0xFF & result.ebx >> 8),
        @truncate(0xFF & result.ebx >> 16),
        @truncate(0xFF & result.ebx >> 24),

        @truncate(0xFF & result.edx),
        @truncate(0xFF & result.edx >> 8),
        @truncate(0xFF & result.edx >> 16),
        @truncate(0xFF & result.edx >> 24),

        @truncate(0xFF & result.ecx),
        @truncate(0xFF & result.ecx >> 8),
        @truncate(0xFF & result.ecx >> 16),
        @truncate(0xFF & result.ecx >> 24),
    };

    return manufacturer_bytes;
}
