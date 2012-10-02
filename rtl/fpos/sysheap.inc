function SysOSAlloc(size: ptruint): pointer; external name 'MemAlloc';

{$define HAS_SYSOSFREE}

procedure SysOSFree(p: pointer; size: ptruint); external name 'MemFree';
