; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -LowerWGScope -S | FileCheck %s

; Test to check that shadow local variable for byval argument is
; materialized before use. Otherwise invalid cast between address
; spaces is generated.

%struct.widget = type { %struct.baz, %struct.baz, %struct.baz, %struct.spam }
%struct.baz = type { %struct.snork }
%struct.snork = type { [1 x i64] }
%struct.spam = type { %struct.snork }


declare dso_local spir_func void @zot(i8*)

; CHECK: @[[SHADOW:[a-zA-Z0-9]+]] = internal unnamed_addr addrspace(3) global %struct.widget undef, align 16

; Function Attrs: inlinehint norecurse
define dso_local spir_func void @wombat(%struct.widget* byval(%struct.widget) align 8 %arg) align 2 !work_group_scope !1 {
; CHECK-LABEL: @wombat(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP0:%.*]] = load i64, i64 addrspace(1)* @__spirv_BuiltInLocalInvocationIndex, align 4
; CHECK-NEXT:    call void @_Z22__spirv_ControlBarrierjjj(i32 2, i32 2, i32 272)
; CHECK-NEXT:    [[CMPZ1:%.*]] = icmp eq i64 [[TMP0]], 0
; CHECK-NEXT:    br i1 [[CMPZ1]], label [[LEADER:%.*]], label [[MERGE:%.*]]
; CHECK:       leader:
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast %struct.widget* [[ARG:%.*]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p3i8.p0i8.i64(i8 addrspace(3)* align 16 bitcast (%struct.widget addrspace(3)* @[[SHADOW]] to i8 addrspace(3)*), i8* align 8 [[TMP1]], i64 32, i1 false)
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    call void @_Z22__spirv_ControlBarrierjjj(i32 2, i32 2, i32 272) #0
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast %struct.widget* [[ARG]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p3i8.i64(i8* align 8 [[TMP2]], i8 addrspace(3)* align 16 bitcast (%struct.widget addrspace(3)* @[[SHADOW]] to i8 addrspace(3)*), i64 32, i1 false)
; CHECK-NEXT:    [[TMP3:%.*]] = load i64, i64 addrspace(1)* @__spirv_BuiltInLocalInvocationIndex, align 4
; CHECK-NEXT:    call void @_Z22__spirv_ControlBarrierjjj(i32 2, i32 2, i32 272)
; CHECK-NEXT:    [[CMPZ:%.*]] = icmp eq i64 [[TMP3]], 0
; CHECK-NEXT:    br i1 [[CMPZ]], label [[WG_LEADER:%.*]], label [[WG_CF:%.*]]
; CHECK:       wg_leader:
; CHECK-NEXT:    [[TMP:%.*]] = bitcast %struct.widget* [[ARG]] to i8*
; CHECK-NEXT:    call void @zot(i8* [[TMP]])
; CHECK-NEXT:    br label [[WG_CF]]
; CHECK:       wg_cf:
; CHECK-NEXT:    call void @_Z22__spirv_ControlBarrierjjj(i32 2, i32 2, i32 272) #0
; CHECK-NEXT:    ret void
;
bb:
  %tmp = bitcast %struct.widget* %arg to i8*
  call void @zot(i8* %tmp)
  ret void
}

!1 = !{}
