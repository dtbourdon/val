" Vim global plugin to provide convienence commands around ack
" Maintainer:	Troy Bourdon
" License:	This file is placed in the public domain.

let s:valDefaultBufferHeight = 15
let s:valBufferName = 'VAL-BUFFER'
let s:valBufferList = []
let s:valCommandHistory = []

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""" Buffer management fucntions """"""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! g:ValPopulateBuffer(results)
	let l:idx = 0 
	for l:result in a:results
		let l:idx += 1
		call setline(l:idx, l:result)
	endfor
endfunction

function! g:ValShowBuffer(results)
	if (bufwinnr(s:valBufferName) >= 0)
		exec bufwinnr(s:valBufferName) . 'wincmd w'
		exec 'normal ggdG'
	else
		exec s:valDefaultBufferHeight . ' new ' . s:valBufferName	
		setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
	endif

	call g:ValPopulateBuffer(a:results)
endfunction

function! g:ValPopulateBufferList(list)
	let s:valBufferList = []
	for l:item in a:list
		call add(s:valBufferList, l:item)
	endfor

	return s:valBufferList
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""" System command wrapper """"""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""
function! g:ValAckCommand(command)
	call add(s:valCommandHistory, a:command)
	let l:commandResults = system(a:command)

	if(strlen(l:commandResults) == 0)
		echo 'ValMessage: No results found.'
		return
	endif

	let l:commandResultsList = split(l:commandResults)
	if(l:commandResultsList[0] == 'ack:')
		echo 'ValMessage: ' . l:commandResults 
	else
		call g:ValShowBuffer(g:ValPopulateBufferList(l:commandResultsList))
	endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""" Function to open transcript/command history results """"""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! g:ValTranscript()
	if(len(s:valCommandHistory) > 0)
		"call g:ValShowBuffer(g:valCommandHistory)
		call g:ValShowBuffer(g:ValPopulateBufferList(s:valCommandHistory))
	else
		echo 'ValMessage: Currently there is no command history.'
	endif
endfunction
command! -nargs=0 ValTranscript call g:ValTranscript()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""" Function to open selected result from transcript list """"""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! g:ValTranscriptOpen()
	let l:command = s:valCommandHistory[line(".") - 1]
	call g:ValAckCommand(l:command)
endfunction
command! -nargs=0 ValTranscriptOpen call g:ValTranscriptOpen()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""" Function to open last/current command results """"""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! g:ValLast()
	if(len(s:valBufferList) > 0)
		call g:ValShowBuffer(s:valBufferList)
	else
		echo 'ValMessage: Currently there are no results in ' . s:valBufferName . '.'
	endif
endfunction
command! -nargs=0 ValLast call g:ValLast()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""" Function to open selected result from results list """"""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! g:ValOpen()
	let l:file = s:valBufferList[line(".") - 1]
	q
	exec 'e ' . l:file
endfunction
command! -nargs=0 ValOpen call g:ValOpen()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""" Convinenece functions around the Ack executable """"""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! g:ValFile(pattern)
	call g:ValAckCommand('ack -g ' . a:pattern)
endfunction
command! -nargs=1 ValFile call g:ValFile(<f-args>)

function! g:ValGroovy(pattern)
	call g:ValAckCommand('ack -g ' . a:pattern . ' --groovy --ignore-dir target')
endfunction
command! -nargs=1 ValGroovy call g:ValGroovy(<f-args>)
command! -nargs=0 ValGroovyType call g:ValGroovy(expand('<cword>'))

function! g:ValHTML(pattern)
	call g:ValSystem('ack -g ' . a:pattern . ' --html --ignore-dir target')
endfunction
command! -nargs=1 ValHTML call g:ValHTML(<f-args>)

function! g:ValJava(pattern)
	call g:ValAckCommand('ack -g ' . a:pattern . ' --java --ignore-dir target')
endfunction
command! -nargs=1 ValJava call g:ValJava(<f-args>)
command! -nargs=0 ValJavaType call g:ValJava(expand('<cword>'))

function! g:ValXML(pattern)
	call g:ValAckCommand('ack -g ' . a:pattern . ' --xml --ignore-dir target')
endfunction
command! -nargs=1 ValXML call g:ValXML(<f-args>)

function! g:ValBufferResize(size)
	let s:valDefaultBufferHeight = a:size
endfunction
command! -nargs=1 ValBufferResize call g:ValBufferResize(<f-args>)

function! g:ValSystem(command)
	call add(s:valCommandHistory, a:command)
	let l:commandResults = system(a:command)

	if(strlen(l:commandResults) == 0)
		echo 'ValMessage: No results found.'
		return
	endif

	let l:commandResultsList = [l:commandResults]
	call g:ValShowBuffer(g:ValPopulateBufferList(l:commandResultsList))
endfunction
command! -nargs=1 ValSystem call g:ValSystem(<f-args>)
