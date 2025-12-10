" Vim syntax file for Natural 4GL (Software AG)
" Maintainer: [Your Name]
" Version: 1.0

if exists("b:current_syntax")
    finish
endif

syntax case ignore  " Natural is case-insensitive

" Keywords
syntax keyword naturalKeyword DEFINE SUBROUTINE FUNCTION PROGRAM
syntax keyword naturalKeyword END END-DEFINE RETURN
syntax keyword naturalKeyword CALL PERFORM INCLUDE
syntax keyword naturalKeyword INPUT PRINT WRITE DISPLAY
syntax keyword naturalKeyword REDEFINE LOCAL GLOBAL 
syntax keyword naturalKeyword IF THEN ELSE END-IF
syntax keyword naturalKeyword FOR TO STEP BY END-FOR
syntax keyword naturalKeyword WHILE DO REPEAT END-DO
syntax keyword naturalKeyword DECIDE ON VALUE NONE
syntax keyword naturalKeyword HISTOGRAM FIND READ UPDATE DELETE STORE

" Operators
syntax match naturalOperator "[-+*/=<>]"

" Data Types
syntax keyword naturalType ALPHA NUMERIC DATE TIME LOGICAL INTEGER FLOAT

" Built-in Functions
syntax keyword naturalFunction *DATX *DAT4E *TIME *TIMN *LINE *PAGE *COUNTER

" Comments
syntax match naturalComment "\*\*.*$" contains=naturalTodo
syntax keyword naturalTodo TODO FIXME XXX contained

" Strings
syntax region naturalString start='"' end='"' contains=naturalEscape
syntax match naturalEscape "\\."

" Numbers
syntax match naturalNumber "\<\d\+\>"

" Labels (beginning of a line, followed by a colon)
syntax match naturalLabel "^\s*[A-Za-z0-9_-]\+:\s"

" Define highlight groups
highlight link naturalKeyword Keyword
highlight link naturalOperator Operator
highlight link naturalType Type
highlight link naturalFunction Function
highlight link naturalComment Comment
highlight link naturalTodo Todo
highlight link naturalString String
highlight link naturalEscape SpecialChar
highlight link naturalNumber Number
highlight link naturalLabel Label

let b:current_syntax = "natural"

