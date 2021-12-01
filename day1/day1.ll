%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, %struct._IO_codecvt*, %struct._IO_wide_data*, %struct._IO_FILE*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type opaque
%struct._IO_codecvt = type opaque
%struct._IO_wide_data = type opaque

@input_file = private constant [10 x i8] c"input.txt\00"
@r = private constant [2 x i8] c"r\00"
@strformat = private constant [4 x i8] c"%d\0A\00"

declare %struct._IO_FILE* @fopen(i8*, i8*)
declare i8* @fgets(i8*, i32, %struct._IO_FILE*)
declare i32 @fclose(%struct._IO_FILE*)
declare i32 @printf(i8*, ...)
declare i32 @atoi(i8*)

define i32 @main() {
  %lineno = alloca i64
  store i64 0, i64* %lineno
  %converted_lines = alloca [2000 x i32]
  %current_line = alloca i64
  store i64 0, i64* %current_line
  %lines = alloca [2000 x [50 x i8]]

  %file = call %struct._IO_FILE* @fopen(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @input_file, i64 0, i64 0), i8* getelementptr inbounds ([2 x i8], [2 x i8]* @r, i64 0, i64 0))
  %file_null_check = icmp eq %struct._IO_FILE* %file, null
  br i1 %file_null_check, label %filebad, label %loadline

filebad:
  ret i32 1

loadline:
  %lineno.no = load i64, i64* %lineno
  %lineptr = getelementptr inbounds [2000 x [50 x i8]], [2000 x [50 x i8]]* %lines, i64 0, i64 %lineno.no
  %charptr = getelementptr inbounds [50 x i8], [50 x i8]* %lineptr, i64 0, i64 0
  %fgets_return = call i8* @fgets(i8* %charptr, i32 50, %struct._IO_FILE* %file)
  %fgets_null_check = icmp eq i8* %fgets_return, null
  br i1 %fgets_null_check, label %closefile, label %nextline

nextline:
  %lineno.tmp = add i64 %lineno.no, 1
  store i64 %lineno.tmp, i64* %lineno
  br label %loadline

closefile:
  %skip_file_close_result = call i32 @fclose(%struct._IO_FILE* %file)
  br label %convert

convert:
  %current_line.no = load i64, i64* %current_line
  %linetoconvert = getelementptr inbounds [2000 x [50 x i8]], [2000 x [50 x i8]]* %lines, i64 0, i64 %current_line.no
  %linetoconvert.ptr = getelementptr inbounds [50 x i8], [50 x i8]* %linetoconvert, i64 0, i64 0
  %linetoconvert.cvrtd = call i32 @atoi(i8* %linetoconvert.ptr)
  %converted_lines.ptr = getelementptr inbounds [2000 x i32], [2000 x i32]* %converted_lines, i64 0, i64 %current_line.no
  store i32 %linetoconvert.cvrtd, i32* %converted_lines.ptr
  %current_line.tmp = add i64 %current_line.no, 1
  store i64 %current_line.tmp, i64* %current_line
  %check_convertloop = icmp eq i64 %current_line.no, 2000
  br i1 %check_convertloop, label %solve, label %convert

solve:
  %result.1 = call i32 @solve_1([2000 x i32]* %converted_lines)
  %result.2 = call i32 @solve_2([2000 x i32]* %converted_lines)

  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @strformat, i64 0, i64 0), i32 %result.1)
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @strformat, i64 0, i64 0), i32 %result.2)

  ret i32 0
}

define i32 @solve_1([2000 x i32]* %lines) {
  ; Store the number of increments
  %result = alloca i32
  store i32 0, i32* %result
  ; Store the index into the array (start at 1 because first entry can't affect result)
  %ix = alloca i64
  store i64 1, i64* %ix
  ; Store the index into the previous entry in the array
  %ix.prev = alloca i64
  store i64 0, i64* %ix.prev
  br label %loop

loop:
  %ix.val = load i64, i64* %ix
  %ix.prev.val = load i64, i64* %ix.prev
  %x = getelementptr inbounds [2000 x i32], [2000 x i32]* %lines, i64 0, i64 %ix.val
  %x.prev = getelementptr inbounds [2000 x i32], [2000 x i32]* %lines, i64 0, i64 %ix.prev.val
  %x.val = load i32, i32* %x
  %x.prev.val = load i32, i32* %x.prev
  %is_inc = icmp slt i32 %x.prev.val, %x.val
  br i1 %is_inc, label %incresult, label %nextindex

incresult:
  %result.val = load i32, i32* %result
  %result.tmp = add i32 %result.val, 1
  store i32 %result.tmp, i32* %result
  br label %nextindex

nextindex:
  %ix.tmp = add i64 %ix.val, 1
  %ix.prev.tmp = add i64 %ix.prev.val, 1
  store i64 %ix.tmp, i64* %ix
  store i64 %ix.prev.tmp, i64* %ix.prev
  %checkend = icmp eq i64 %ix.val, 2000
  br i1 %checkend, label %return, label %loop

return:
  %result.end = load i32, i32* %result
  ret i32 %result.end
}


define i32 @solve_2([2000 x i32]* %lines) {
  ; Store the number of increments
  %result = alloca i32
  store i32 -1, i32* %result
  ; Store the three indexes into the array
  %ix.1 = alloca i64
  %ix.2 = alloca i64
  %ix.3 = alloca i64
  store i64 0, i64* %ix.1
  store i64 1, i64* %ix.2
  store i64 2, i64* %ix.3
  ; Track the previous sum value
  %sum.prev = alloca i32
  store i32 0, i32* %sum.prev
  br label %loop

loop:
  %ix.1.val = load i64, i64* %ix.1
  %ix.2.val = load i64, i64* %ix.2
  %ix.3.val = load i64, i64* %ix.3
  %x.1 = getelementptr inbounds [2000 x i32], [2000 x i32]* %lines, i64 0, i64 %ix.1.val
  %x.2 = getelementptr inbounds [2000 x i32], [2000 x i32]* %lines, i64 0, i64 %ix.2.val
  %x.3 = getelementptr inbounds [2000 x i32], [2000 x i32]* %lines, i64 0, i64 %ix.3.val
  %x.1.val = load i32, i32* %x.1
  %x.2.val = load i32, i32* %x.2
  %x.3.val = load i32, i32* %x.3
  %sum.tmp = add i32 %x.1.val, %x.2.val
  %sum = add i32 %sum.tmp, %x.3.val
  %sum.prev.val = load i32, i32* %sum.prev
  %is_inc = icmp slt i32 %sum.prev.val, %sum
  store i32 %sum, i32* %sum.prev
  br i1 %is_inc, label %incresult, label %nextindex

incresult:
  %result.val = load i32, i32* %result
  %result.tmp = add i32 %result.val, 1
  store i32 %result.tmp, i32* %result
  br label %nextindex

nextindex:
  %ix.1.tmp = add i64 %ix.1.val, 1
  %ix.2.tmp = add i64 %ix.2.val, 1
  %ix.3.tmp = add i64 %ix.3.val, 1
  store i64 %ix.1.tmp, i64* %ix.1
  store i64 %ix.2.tmp, i64* %ix.2
  store i64 %ix.3.tmp, i64* %ix.3
  %checkend = icmp eq i64 %ix.3.val, 2000
  br i1 %checkend, label %return, label %loop

return:
  %result.end = load i32, i32* %result
  ret i32 %result.end
}