; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefix=X64
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefix=X64

; PR3253

; The register+memory form of the BT instruction should be usable on
; pentium4, however it is currently disabled due to the register+memory
; form having different semantics than the register+register form.

; Test these patterns:
;    (X & (1 << N))  != 0  -->  BT(X, N).
;    ((X >>u N) & 1) != 0  -->  BT(X, N).
; as well as several variations:
;    - The second form can use an arithmetic shift.
;    - Either form can use == instead of !=.
;    - Either form can compare with an operand of the &
;      instead of with 0.
;    - The comparison can be commuted (only cases where neither
;      operand is constant are included).
;    - The and can be commuted.

define void @test2(i32 %x, i32 %n) nounwind {
; X86-LABEL: test2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jb .LBB0_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB0_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: test2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jb .LBB0_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB0_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = lshr i32 %x, %n
  %tmp3 = and i32 %tmp29, 1
  %tmp4 = icmp eq i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @test2b(i32 %x, i32 %n) nounwind {
; X86-LABEL: test2b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB1_1
; X86-NEXT:  # %bb.2: # %UnifiedReturnBlock
; X86-NEXT:    retl
; X86-NEXT:  .LBB1_1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:    retl
;
; X64-LABEL: test2b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB1_1
; X64-NEXT:  # %bb.2: # %UnifiedReturnBlock
; X64-NEXT:    retq
; X64-NEXT:  .LBB1_1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:    retq
entry:
  %tmp29 = lshr i32 %x, %n
  %tmp3 = and i32 1, %tmp29
  %tmp4 = icmp eq i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @atest2(i32 %x, i32 %n) nounwind {
; X86-LABEL: atest2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jb .LBB2_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB2_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: atest2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jb .LBB2_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB2_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = ashr i32 %x, %n
  %tmp3 = and i32 %tmp29, 1
  %tmp4 = icmp eq i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @atest2b(i32 %x, i32 %n) nounwind {
; X86-LABEL: atest2b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB3_1
; X86-NEXT:  # %bb.2: # %UnifiedReturnBlock
; X86-NEXT:    retl
; X86-NEXT:  .LBB3_1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:    retl
;
; X64-LABEL: atest2b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB3_1
; X64-NEXT:  # %bb.2: # %UnifiedReturnBlock
; X64-NEXT:    retq
; X64-NEXT:  .LBB3_1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:    retq
entry:
  %tmp29 = ashr i32 %x, %n
  %tmp3 = and i32 1, %tmp29
  %tmp4 = icmp eq i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @test3(i32 %x, i32 %n) nounwind {
; X86-LABEL: test3:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB4_1
; X86-NEXT:  # %bb.2: # %UnifiedReturnBlock
; X86-NEXT:    retl
; X86-NEXT:  .LBB4_1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:    retl
;
; X64-LABEL: test3:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB4_1
; X64-NEXT:  # %bb.2: # %UnifiedReturnBlock
; X64-NEXT:    retq
; X64-NEXT:  .LBB4_1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %tmp29, %x
  %tmp4 = icmp eq i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @test3b(i32 %x, i32 %n) nounwind {
; X86-LABEL: test3b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB5_1
; X86-NEXT:  # %bb.2: # %UnifiedReturnBlock
; X86-NEXT:    retl
; X86-NEXT:  .LBB5_1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:    retl
;
; X64-LABEL: test3b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB5_1
; X64-NEXT:  # %bb.2: # %UnifiedReturnBlock
; X64-NEXT:    retq
; X64-NEXT:  .LBB5_1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %x, %tmp29
  %tmp4 = icmp eq i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @testne2(i32 %x, i32 %n) nounwind {
; X86-LABEL: testne2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB6_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB6_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: testne2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB6_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB6_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = lshr i32 %x, %n
  %tmp3 = and i32 %tmp29, 1
  %tmp4 = icmp ne i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @testne2b(i32 %x, i32 %n) nounwind {
; X86-LABEL: testne2b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB7_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB7_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: testne2b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB7_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB7_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = lshr i32 %x, %n
  %tmp3 = and i32 1, %tmp29
  %tmp4 = icmp ne i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @atestne2(i32 %x, i32 %n) nounwind {
; X86-LABEL: atestne2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB8_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB8_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: atestne2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB8_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB8_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = ashr i32 %x, %n
  %tmp3 = and i32 %tmp29, 1
  %tmp4 = icmp ne i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @atestne2b(i32 %x, i32 %n) nounwind {
; X86-LABEL: atestne2b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB9_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB9_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: atestne2b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB9_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB9_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = ashr i32 %x, %n
  %tmp3 = and i32 1, %tmp29
  %tmp4 = icmp ne i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @testne3(i32 %x, i32 %n) nounwind {
; X86-LABEL: testne3:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB10_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB10_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: testne3:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB10_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB10_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %tmp29, %x
  %tmp4 = icmp ne i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @testne3b(i32 %x, i32 %n) nounwind {
; X86-LABEL: testne3b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB11_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB11_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: testne3b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB11_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB11_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %x, %tmp29
  %tmp4 = icmp ne i32 %tmp3, 0
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @query2(i32 %x, i32 %n) nounwind {
; X86-LABEL: query2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB12_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB12_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: query2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB12_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB12_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = lshr i32 %x, %n
  %tmp3 = and i32 %tmp29, 1
  %tmp4 = icmp eq i32 %tmp3, 1
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @query2b(i32 %x, i32 %n) nounwind {
; X86-LABEL: query2b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB13_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB13_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: query2b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB13_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB13_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = lshr i32 %x, %n
  %tmp3 = and i32 1, %tmp29
  %tmp4 = icmp eq i32 %tmp3, 1
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @aquery2(i32 %x, i32 %n) nounwind {
; X86-LABEL: aquery2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB14_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB14_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: aquery2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB14_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB14_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = ashr i32 %x, %n
  %tmp3 = and i32 %tmp29, 1
  %tmp4 = icmp eq i32 %tmp3, 1
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @aquery2b(i32 %x, i32 %n) nounwind {
; X86-LABEL: aquery2b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB15_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB15_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: aquery2b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB15_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB15_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = ashr i32 %x, %n
  %tmp3 = and i32 1, %tmp29
  %tmp4 = icmp eq i32 %tmp3, 1
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @query3(i32 %x, i32 %n) nounwind {
; X86-LABEL: query3:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB16_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB16_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: query3:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB16_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB16_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %tmp29, %x
  %tmp4 = icmp eq i32 %tmp3, %tmp29
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @query3b(i32 %x, i32 %n) nounwind {
; X86-LABEL: query3b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB17_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB17_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: query3b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB17_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB17_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %x, %tmp29
  %tmp4 = icmp eq i32 %tmp3, %tmp29
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @query3x(i32 %x, i32 %n) nounwind {
; X86-LABEL: query3x:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB18_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB18_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: query3x:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB18_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB18_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %tmp29, %x
  %tmp4 = icmp eq i32 %tmp29, %tmp3
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @query3bx(i32 %x, i32 %n) nounwind {
; X86-LABEL: query3bx:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jae .LBB19_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB19_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: query3bx:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jae .LBB19_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB19_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %x, %tmp29
  %tmp4 = icmp eq i32 %tmp29, %tmp3
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @queryne2(i32 %x, i32 %n) nounwind {
; X86-LABEL: queryne2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jb .LBB20_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB20_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: queryne2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jb .LBB20_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB20_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = lshr i32 %x, %n
  %tmp3 = and i32 %tmp29, 1
  %tmp4 = icmp ne i32 %tmp3, 1
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @queryne2b(i32 %x, i32 %n) nounwind {
; X86-LABEL: queryne2b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jb .LBB21_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB21_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: queryne2b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jb .LBB21_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB21_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = lshr i32 %x, %n
  %tmp3 = and i32 1, %tmp29
  %tmp4 = icmp ne i32 %tmp3, 1
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @aqueryne2(i32 %x, i32 %n) nounwind {
; X86-LABEL: aqueryne2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jb .LBB22_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB22_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: aqueryne2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jb .LBB22_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB22_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = ashr i32 %x, %n
  %tmp3 = and i32 %tmp29, 1
  %tmp4 = icmp ne i32 %tmp3, 1
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @aqueryne2b(i32 %x, i32 %n) nounwind {
; X86-LABEL: aqueryne2b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jb .LBB23_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB23_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: aqueryne2b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jb .LBB23_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB23_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = ashr i32 %x, %n
  %tmp3 = and i32 1, %tmp29
  %tmp4 = icmp ne i32 %tmp3, 1
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @queryne3(i32 %x, i32 %n) nounwind {
; X86-LABEL: queryne3:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jb .LBB24_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB24_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: queryne3:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jb .LBB24_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB24_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %tmp29, %x
  %tmp4 = icmp ne i32 %tmp3, %tmp29
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @queryne3b(i32 %x, i32 %n) nounwind {
; X86-LABEL: queryne3b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jb .LBB25_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB25_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: queryne3b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jb .LBB25_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB25_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %x, %tmp29
  %tmp4 = icmp ne i32 %tmp3, %tmp29
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @queryne3x(i32 %x, i32 %n) nounwind {
; X86-LABEL: queryne3x:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jb .LBB26_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB26_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: queryne3x:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jb .LBB26_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB26_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %tmp29, %x
  %tmp4 = icmp ne i32 %tmp29, %tmp3
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

define void @queryne3bx(i32 %x, i32 %n) nounwind {
; X86-LABEL: queryne3bx:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    jb .LBB27_2
; X86-NEXT:  # %bb.1: # %bb
; X86-NEXT:    calll foo
; X86-NEXT:  .LBB27_2: # %UnifiedReturnBlock
; X86-NEXT:    retl
;
; X64-LABEL: queryne3bx:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    jb .LBB27_2
; X64-NEXT:  # %bb.1: # %bb
; X64-NEXT:    pushq %rax
; X64-NEXT:    callq foo
; X64-NEXT:    popq %rax
; X64-NEXT:  .LBB27_2: # %UnifiedReturnBlock
; X64-NEXT:    retq
entry:
  %tmp29 = shl i32 1, %n
  %tmp3 = and i32 %x, %tmp29
  %tmp4 = icmp ne i32 %tmp29, %tmp3
  br i1 %tmp4, label %bb, label %UnifiedReturnBlock

bb:
  call void @foo()
  ret void

UnifiedReturnBlock:
  ret void
}

declare void @foo()

define zeroext i1 @invert(i32 %flags, i32 %flag) nounwind {
; X86-LABEL: invert:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    notl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    setb %al
; X86-NEXT:    retl
;
; X64-LABEL: invert:
; X64:       # %bb.0:
; X64-NEXT:    notl %edi
; X64-NEXT:    btl %esi, %edi
; X64-NEXT:    setb %al
; X64-NEXT:    retq
  %neg = xor i32 %flags, -1
  %shl = shl i32 1, %flag
  %and = and i32 %shl, %neg
  %tobool = icmp ne i32 %and, 0
  ret i1 %tobool
}

define zeroext i1 @extend(i32 %bit, i64 %bits) {
; X86-LABEL: extend:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    setb %al
; X86-NEXT:    retl
;
; X64-LABEL: extend:
; X64:       # %bb.0: # %entry
; X64-NEXT:    btl %edi, %esi
; X64-NEXT:    setb %al
; X64-NEXT:    retq
entry:
  %and = and i32 %bit, 31
  %sh_prom = zext i32 %and to i64
  %shl = shl i64 1, %sh_prom
  %and1 = and i64 %shl, %bits
  %tobool = icmp ne i64 %and1, 0
  ret i1 %tobool
}

; TODO: BT fails to look through to demanded bits as c%32 has more than one use.
; void demanded_i32(int *a, int *b, unsigned c) {
;   if ((a[c/32] >> (c % 32)) & 1)
;     b[c/32] |= 1 << (c % 32);
; }
define void @demanded_i32(i32* nocapture readonly, i32* nocapture, i32) nounwind {
; X86-LABEL: demanded_i32:
; X86:       # %bb.0:
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl %ecx, %eax
; X86-NEXT:    shrl $5, %eax
; X86-NEXT:    movl (%edx,%eax,4), %esi
; X86-NEXT:    movl $1, %edx
; X86-NEXT:    shll %cl, %edx
; X86-NEXT:    btl %ecx, %esi
; X86-NEXT:    jae .LBB30_2
; X86-NEXT:  # %bb.1:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    orl %edx, (%ecx,%eax,4)
; X86-NEXT:  .LBB30_2:
; X86-NEXT:    popl %esi
; X86-NEXT:    retl
;
; X64-LABEL: demanded_i32:
; X64:       # %bb.0:
; X64-NEXT:    movl %edx, %ecx
; X64-NEXT:    movl %edx, %eax
; X64-NEXT:    shrl $5, %eax
; X64-NEXT:    movl (%rdi,%rax,4), %edi
; X64-NEXT:    movl $1, %edx
; X64-NEXT:    shll %cl, %edx
; X64-NEXT:    btl %ecx, %edi
; X64-NEXT:    jae .LBB30_2
; X64-NEXT:  # %bb.1:
; X64-NEXT:    orl %edx, (%rsi,%rax,4)
; X64-NEXT:  .LBB30_2:
; X64-NEXT:    retq
  %4 = lshr i32 %2, 5
  %5 = zext i32 %4 to i64
  %6 = getelementptr inbounds i32, i32* %0, i64 %5
  %7 = load i32, i32* %6, align 4
  %8 = and i32 %2, 31
  %9 = shl i32 1, %8
  %10 = and i32 %7, %9
  %11 = icmp eq i32 %10, 0
  br i1 %11, label %16, label %12

; <label>:12:
  %13 = getelementptr inbounds i32, i32* %1, i64 %5
  %14 = load i32, i32* %13, align 4
  %15 = or i32 %14, %9
  store i32 %15, i32* %13, align 4
  br label %16

; <label>:16:
  ret void
}

; Make sure we can simplify bt when the shift amount has known zeros in it
; which cause the and mask to have bits removed.
define zeroext i1 @demanded_with_known_zeroes(i32 %bit, i32 %bits) {
; X86-LABEL: demanded_with_known_zeroes:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-NEXT:    shlb $2, %cl
; X86-NEXT:    movzbl %cl, %ecx
; X86-NEXT:    btl %ecx, %eax
; X86-NEXT:    setb %al
; X86-NEXT:    retl
;
; X64-LABEL: demanded_with_known_zeroes:
; X64:       # %bb.0: # %entry
; X64-NEXT:    shlb $2, %dil
; X64-NEXT:    movzbl %dil, %eax
; X64-NEXT:    btl %eax, %esi
; X64-NEXT:    setb %al
; X64-NEXT:    retq
entry:
  %bit2 = shl i32 %bit, 2
  %and = and i32 %bit2, 31
  %shl = shl i32 1, %and
  %and1 = and i32 %shl, %bits
  %tobool = icmp ne i32 %and1, 0
  ret i1 %tobool
}
