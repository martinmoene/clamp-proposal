@echo off

setlocal

set title=clamp: An algorithm to 'clamp' a value between a pair of boundary values

for %%f in (*.md) do (

   echo %%f:
   pandoc -f markdown -t html5 --standalone --self-contained --title-prefix="%title%" --base-header-level=1 --include-in-header=mk-md-html.css -o %%~nf.html %%f
)

endlocal
