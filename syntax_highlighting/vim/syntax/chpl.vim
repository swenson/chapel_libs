" Vim syntax file
" " Language: Chapel
" " Maintainer: Christopher Swenson <chris@caswenson.com>
" " Last Change:  2010 May 29
"
" " For version 5.x: Clear all syntax items
" " For version 6.x: Quit when a syntax file was already loaded
"
" This is still very incomplete, but it is a start

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif
syntax case match
syn keyword chplStatement def class use var const config for do until unless in while if then else param module type select when otherwise return label break continue forall sync single new range enum reduce scan yield here this cobegin coforall begin sparse subdomain dmap dmapped opaque _extern 
syn keyword chplTodo contained TODO FIXME XXX
syn match chplInteger "[0-9]+"
syn match chplOperator "[{};:\[\](),]"
syn match chplOperator "\.\." "\."
syn match chplOperator "<" ">"
syn match chplOperator "+" "-" "*" "/" "^" "=" "&" "|" "!" "%" "~"
syn match chplOperator "**"
syn match chplOperator "&&"
syn match chplOperator "||"
syn match chplOperator "<="
syn match chplOperator ">="
syn match chplOperator "+="
syn match chplOperator "-="
syn match chplOperator "*="
syn match chplOperator "/="
syn match chplOperator "%="
syn match chplOperator "&="
syn match chplOperator "|="
syn match chplOperator "^="
syn match chplOperator "&&="
syn match chplOperator "||="
syn match chplOperator ">>="
syn match chplOperator "<<="
syn match chplOperator "**="
syn match chplOperator "<=>"
syn match chplEscape +\\[abfnrtv'"\\]+ contained
syn match chplEscape "\x[0-9a-fA-F]+" contained
syn region chplString start="\"" end="\"" contains=chplEscape
syn region chplString start="'" end="'" contains=chplEscape
syn region chplComment start="//" end="$" contains=chplTodo
syn region chplComment start="/\*" end="\*/" contains=chplTodo
syn keyword chplClass FileAccessMode
syn keyword chplFunction length ascii substring write writeln read close
syn keyword chplFunction QuickSort
syn match chplType "\(int\|uint\|real\|imag\|complex\)\((\(8|16|32\|64\|128\|256\))\)\="
syn keyword chplType string domain  bool
if version >= 508 || !exists("did_chpl_syn_inits")
  if version < 508
    let did_chpl_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink chplType Statement
  HiLink chplInteger Number
  HiLink chplOperator Operator
  HiLink chplComment Comment
  HiLink chplTodo Todo
  HiLink chplStatement Statement
  HiLink chplString String
  HiLink chplFunction Function
  HiLink chplClass Function

  delcommand HiLink
endif

let b:current_syntax = "chpl"
