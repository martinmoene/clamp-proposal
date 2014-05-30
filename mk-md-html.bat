@echo off

setlocal

for %%f in (*.md) do (

   echo %%f:
   pandoc -f markdown -t html5 --standalone --self-contained --base-header-level=1 --include-in-header=mk-md-html.css -o %%~nf.html %%f
)

endlocal
