" Vim global plugin to provide convienence wrappers around various system commands.
" Maintainer:	Troy Bourdon
" License:	This file is placed in the public domain.

let s:valDefaultBufferHeight = 15
let s:valDefaultNerdTreeWidth = 50
let s:valBufferName = 'VAL-BUFFER'
let s:valBufferList = []
let s:valCommandHistory = []

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""" Buffer management functions """"""""""""""""""
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
""""""""""""" System command wrapper """""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""

function! g:ValSystemCommand(command)
	call add(s:valCommandHistory, a:command)
	let l:commandResults = system(a:command)

	if(strlen(l:commandResults) == 0)
		echo 'ValMessage: No results found.'
		return
	endif

	let l:commandResultsList = split(l:commandResults)
	call g:ValShowBuffer(g:ValPopulateBufferList(l:commandResultsList))
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
	call g:ValSystemCommand(l:command)
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
""""""""""""" Convinenece functions around the find command """"""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! g:ValFile(pattern)
	call g:ValSystemCommand('find -H -type f -name *' . a:pattern . '*')
endfunction
command! -nargs=1 ValFile call g:ValFile(<f-args>)

function! g:ValProps(pattern)
	call g:ValSystemCommand('find -H -type f -name *' . a:pattern . '*.properties')
endfunction
command! -nargs=1 ValProps call g:ValProps(<f-args>)

function! g:ValGroovy(pattern)
	call g:ValSystemCommand('find -H -type f -name *' . a:pattern . '*.groovy')
endfunction
command! -nargs=1 ValGroovy call g:ValGroovy(<f-args>)

function! g:ValGroovyType(pattern)
	call g:ValSystemCommand('find -H -type f -name ' . a:pattern . '.groovy')
endfunction
command! -nargs=0 ValGroovyType call g:ValGroovyType(expand('<cword>'))

function! g:ValHTML(pattern)
	call g:ValSystemCommand('find -H -type f -name *' . a:pattern . '*.html')
endfunction
command! -nargs=1 ValHTML call g:ValHTML(<f-args>)

function! g:ValJava(pattern)
	call g:ValSystemCommand('find -H -type f -name *' . a:pattern . '*.java')
endfunction
command! -nargs=1 ValJava call g:ValJava(<f-args>)

function! g:ValJavaType(pattern)
	call g:ValSystemCommand('find -H -type f -name ' . a:pattern . '.java')
endfunction
command! -nargs=0 ValJavaType call g:ValJavaType(expand('<cword>'))

function! g:ValXML(pattern)
	call g:ValSystemCommand('find -H -type f -name *' . a:pattern . '*.xml')
endfunction
command! -nargs=1 ValXML call g:ValXML(<f-args>)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""" Convinenece functions around the grep command """"""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! g:ValGrepJava(pattern)
	call g:ValSystemCommand('grep -lrw ' . a:pattern . ' --include *.java')
endfunction
command! -nargs=1 ValGrepJava call g:ValGrepJava(<f-args>)
command! -nargs=0 ValGrepJavaType call g:ValGrepJava(expand('<cword>'))

function! g:ValGrepGroovy(pattern)
	call g:ValSystemCommand('grep -lrw ' . a:pattern . ' --include *.groovy')
endfunction
command! -nargs=1 ValGrepGroovy call g:ValGrepGroovy(<f-args>)
command! -nargs=0 ValGrepGroovyType call g:ValGrepGroovy(expand('<cword>'))

function! g:ValGrepHTML(pattern)
	call g:ValSystemCommand('grep -lrw ' . a:pattern . ' --include *.groovy')
endfunction
command! -nargs=1 ValGrepHTML call g:ValGrepHTML(<f-args>)
command! -nargs=0 ValGrepHTMLType call g:ValGrepHTML(expand('<cword>'))

function! g:ValGrepXML(pattern)
	call g:ValSystemCommand('grep -lrw ' . a:pattern . ' --include *.groovy')
endfunction
command! -nargs=1 ValGrepXML call g:ValGrepXML(<f-args>)
command! -nargs=0 ValGrepXMLType call g:ValGrepXML(expand('<cword>'))

function! g:ValBufferResize(size)
	let s:valDefaultBufferHeight = a:size
endfunction
command! -nargs=1 ValBufferResize call g:ValBufferResize(<f-args>)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""" Convinenece wrapper around NERDTree """"""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! g:ValNerdTree()
	exec 'NERDTree'
	exec 'vertical res ' . s:valDefaultNerdTreeWidth
endfunction
command! -nargs=0 ValNerdTree call g:ValNerdTree()

function! g:ValTabRegion()
	'<SHIFT-I>'
	'<TAB>'	
	'<Esc>'
endfunction
command! -nargs=0 ValTabRegion call g:ValTabRegion()

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
